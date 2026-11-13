"use strict";

const _ = require("lodash");
const { execaSync } = require("execa");
const { filesize } = require("filesize");
const { markdownTable } = require("markdown-table");

// Returns the output of `docker manifest inspect -v` for a container image
function inspectManifest(container) {
  const { stdout } = execaSync("docker", [
    "manifest",
    "inspect",
    "-v",
    container,
  ]);
  return stdout;
}

function normalizedReference(container) {
  const parts = container.split("/");
  if (
    parts.length === 1 ||
    (!/[.:]/.test(parts[0]) && parts[0] !== "localhost")
  ) {
    parts.unshift("docker.io");
  }
  if (parts[0] === "index.docker.io") {
    parts[0] = "docker.io";
  }
  if (parts[0] === "docker.io" && parts.length === 2) {
    parts.splice(1, 0, "library");
  }
  return parts.join("/");
}

function isMissingManifest(error, container) {
  if (
    error?.exitCode !== 1 ||
    error.timedOut ||
    error.isCanceled ||
    error.killed ||
    error.signal ||
    typeof error.stderr !== "string"
  ) {
    return false;
  }

  // Match the entire diagnostic so mixed registry/authentication errors stay fatal.
  const diagnostic = error.stderr.trim();
  const missing = /^no such manifest: (\S+)$/.exec(diagnostic);
  return (
    (missing &&
      normalizedReference(missing[1]) === normalizedReference(container)) ||
    /^(?:Error response from daemon: )?(?:manifest unknown|MANIFEST_UNKNOWN)(?:: (?:manifest unknown|The named manifest is not known to the registry\.?))?$/.test(
      diagnostic,
    )
  );
}

// Returns the compressed size of the layers per platform of a container image, as an
// object that maps the platform (e.g. "linux/arm64") to the size in bytes.
function getSizes(container, inspect = inspectManifest) {
  const manifests = _.castArray(JSON.parse(inspect(container).trim()));
  const sizes = _(manifests)
    .map((manifest) => {
      const platform = _.get(manifest, "Descriptor.platform", {});

      const key = _.compact([
        platform.os,
        platform.architecture,
        platform.variant,
        platform["os.version"],
      ]).join("/");

      const layers =
        _.get(manifest, "OCIManifest.layers") || _.get(manifest, "layers");
      if (
        key &&
        !key.includes("unknown") &&
        (!Array.isArray(layers) ||
          layers.some(
            (layer) => !Number.isSafeInteger(layer?.size) || layer.size < 0,
          ))
      ) {
        throw new Error(`Invalid platform sizes found for ${container}`);
      }
      const total = _.sumBy(layers, "size");
      if (key && !key.includes("unknown") && !Number.isSafeInteger(total)) {
        throw new Error(`Invalid platform sizes found for ${container}`);
      }

      return [key, total];
    })
    // Skip the attestation manifests, which have no platform
    .filter(([platform]) => platform && !platform.includes("unknown"))
    .fromPairs()
    .value();

  if (_.isEmpty(sizes)) {
    throw new Error(`No platform sizes found for ${container}`);
  }

  return sizes;
}

function signed(change, text) {
  return `${change >= 0 ? "+" : ""}${text}`;
}

function platformRow(platform, fromSizes, toSizes) {
  const previous = _.get(fromSizes, platform, 0);
  const current = _.get(toSizes, platform, 0);
  const change = current - previous;

  const percentage = previous
    ? signed(change, `${_.round((change / previous) * 100, 2)}%`)
    : current
      ? "+∞"
      : "+0.00%";

  const icon = _.cond([
    [(value) => value < 0, _.constant("🔽")],
    [(value) => value > 0, _.constant("🔼")],
    [_.stubTrue, _.constant("🔄")],
  ])(change);

  return [
    platform,
    filesize(previous),
    filesize(current),
    `${signed(change, filesize(Math.abs(change)))} (${percentage})`,
    icon,
  ];
}

// Returns a markdown report of the size difference between two container images.
function containerSizeDiff(
  fromContainer,
  toContainer,
  inspect = inspectManifest,
) {
  let fromSizes;
  try {
    fromSizes = getSizes(fromContainer, inspect);
  } catch (error) {
    if (!isMissingManifest(error, fromContainer)) {
      throw error;
    }
    fromSizes = null;
  }
  const toSizes = getSizes(toContainer, inspect);

  if (fromSizes === null) {
    const rows = [
      ["OS/Platform", "Current"],
      ..._.keys(toSizes)
        .sort()
        .map((platform) => [platform, filesize(toSizes[platform])]),
    ];

    return `## 📦 Container Size Analysis

> [!NOTE]
> Comparison unavailable: baseline \`${fromContainer}\` does not exist.
> Current image: \`${toContainer}\`

### 📦 Current Image Sizes

${markdownTable(rows, { align: ["l", "c"] })}`;
  }

  const missingFrom = _.difference(_.keys(toSizes), _.keys(fromSizes));
  const missingTo = _.difference(_.keys(fromSizes), _.keys(toSizes));
  if (missingFrom.length || missingTo.length) {
    throw new Error(
      `Platform sets differ; missing from baseline: ${missingFrom.join(", ") || "none"}; ` +
        `missing from current image: ${missingTo.join(", ") || "none"}`,
    );
  }

  const platforms = _.keys(fromSizes).sort();
  const rows = [
    ["OS/Platform", "Previous", "Current", "Change", "Trend"],
    ..._.map(platforms, (platform) =>
      platformRow(platform, fromSizes, toSizes),
    ),
  ];

  return `## 📦 Container Size Analysis

> [!NOTE]
> Comparing \`${fromContainer}\` ➔ \`${toContainer}\`

### 📈 Size Comparison Table

${markdownTable(rows, { align: ["l", "c", "c", "c", "c"] })}`;
}

module.exports = { containerSizeDiff, getSizes };
