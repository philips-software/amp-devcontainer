"use strict";

const assert = require("node:assert/strict");
const { test } = require("node:test");

const { containerSizeDiff, getSizes } = require("../container-size-diff.js");

// The output of `docker manifest inspect -v` for a platform, with fake layer sizes
function platformManifest(platform, ...layerSizes) {
  return {
    Descriptor: { platform },
    OCIManifest: { layers: layerSizes.map((size) => ({ size })) },
  };
}

const amd64 = { os: "linux", architecture: "amd64" };
const arm64 = { os: "linux", architecture: "arm64", variant: "v8" };

// A fake `docker manifest inspect -v`, with the manifests of the fake images by name
function fakeInspect(images) {
  return (container) => {
    if (!(container in images)) {
      throw new Error(`fake: unknown image ${container}`);
    }
    if (images[container] instanceof Error) {
      throw images[container];
    }
    if (typeof images[container] === "string") {
      return images[container];
    }
    return `${JSON.stringify(images[container])}\n`;
  };
}

function inspectionError(stderr, properties = {}) {
  return Object.assign(new Error(`fake inspection failed: ${stderr}`), {
    exitCode: 1,
    stderr,
    ...properties,
  });
}

test("getSizes adds the sizes of the layers per platform", () => {
  const inspect = fakeInspect({
    "fake-image": [
      platformManifest(amd64, 1000, 2000),
      platformManifest(arm64, 4000),
    ],
  });

  assert.deepEqual(getSizes("fake-image", inspect), {
    "linux/amd64": 3000,
    "linux/arm64/v8": 4000,
  });
});

test("getSizes names the platform after the os, architecture, variant and os version", () => {
  const platform = {
    os: "windows",
    architecture: "amd64",
    variant: "fake-variant",
    "os.version": "10.0.1",
  };
  const inspect = fakeInspect({
    "fake-image": [platformManifest(platform, 1000)],
  });

  assert.deepEqual(getSizes("fake-image", inspect), {
    "windows/amd64/fake-variant/10.0.1": 1000,
  });
});

test("getSizes accepts a single manifest, and layers that are not in an OCI manifest", () => {
  const inspect = fakeInspect({
    "fake-image": {
      Descriptor: { platform: amd64 },
      layers: [{ size: 1000 }, { size: 500 }],
    },
  });

  assert.deepEqual(getSizes("fake-image", inspect), { "linux/amd64": 1500 });
});

test("getSizes skips manifests without a known platform", () => {
  const inspect = fakeInspect({
    "fake-image": [
      platformManifest(amd64, 1000),
      platformManifest({ os: "unknown", architecture: "unknown" }, 10),
      platformManifest({}, 10),
    ],
  });

  assert.deepEqual(getSizes("fake-image", inspect), { "linux/amd64": 1000 });
});

test("getSizes fails for an image without platforms", () => {
  const inspect = fakeInspect({
    "fake-image": [
      platformManifest({ os: "unknown", architecture: "unknown" }, 10),
    ],
  });

  assert.throws(
    () => getSizes("fake-image", inspect),
    /No platform sizes found for fake-image/,
  );
});

test("getSizes fails when the image cannot be inspected", () => {
  assert.throws(
    () => getSizes("fake-unknown", fakeInspect({})),
    /fake: unknown image fake-unknown/,
  );
});

test("the report names the images and has a row per platform, sorted by platform", () => {
  const inspect = fakeInspect({
    "fake-from": [platformManifest(arm64, 4000), platformManifest(amd64, 1000)],
    "fake-to": [platformManifest(amd64, 1000), platformManifest(arm64, 4000)],
  });

  const lines = containerSizeDiff("fake-from", "fake-to", inspect).split("\n");

  assert.equal(lines[0], "## 📦 Container Size Analysis");
  assert.equal(lines[2], "> [!NOTE]");
  assert.equal(lines[3], "> Comparing `fake-from` ➔ `fake-to`");
  assert.equal(lines[5], "### 📈 Size Comparison Table");
  assert.match(
    lines[7],
    /^\| OS\/Platform +\| Previous \| Current \| +Change +\| Trend \|$/,
  );
  assert.match(lines[9], /^\| linux\/amd64 /);
  assert.match(lines[10], /^\| linux\/arm64\/v8 /);
  assert.equal(lines.length, 11);
});

test("the report shows the sizes, the change, and a trend per platform", () => {
  const inspect = fakeInspect({
    "fake-from": [
      platformManifest(amd64, 1000),
      platformManifest(arm64, 4000),
      { ...platformManifest({ os: "linux", architecture: "riscv64" }, 2000) },
    ],
    "fake-to": [
      platformManifest(amd64, 2000),
      platformManifest(arm64, 3000),
      { ...platformManifest({ os: "linux", architecture: "riscv64" }, 2000) },
    ],
  });

  const rows = containerSizeDiff("fake-from", "fake-to", inspect)
    .split("\n")
    .slice(9);

  assert.match(
    rows[0],
    /\| linux\/amd64 +\| +1 kB +\| +2 kB +\| +\+1 kB \(\+100%\) +\| +🔼 +\|/,
  );
  assert.match(
    rows[1],
    /\| linux\/arm64\/v8 +\| +4 kB +\| +3 kB +\| +1 kB \(-25%\) +\| +🔽 +\|/,
  );
  assert.match(
    rows[2],
    /\| linux\/riscv64 +\| +2 kB +\| +2 kB +\| +\+0 B \(\+0%\) +\| +🔄 +\|/,
  );
});

test("the report shows a growth from an empty image as infinite", () => {
  const inspect = fakeInspect({
    "fake-from": [
      { Descriptor: { platform: amd64 }, OCIManifest: { layers: [] } },
    ],
    "fake-to": [platformManifest(amd64, 1000)],
  });

  const rows = containerSizeDiff("fake-from", "fake-to", inspect)
    .split("\n")
    .slice(9);

  assert.match(rows[0], /\| +0 B +\| +1 kB +\| +\+1 kB \(\+∞\) +\| +🔼 +\|/);
  assert.doesNotMatch(
    containerSizeDiff("fake-from", "fake-to", inspect),
    /baseline.*does not exist/,
  );
});

test("the report fails when the images are not built for the same platforms", () => {
  const inspect = fakeInspect({
    "fake-from": [platformManifest(amd64, 1000), platformManifest(arm64, 1000)],
    "fake-to": [
      platformManifest(amd64, 1000),
      platformManifest({ os: "linux", architecture: "riscv64" }, 1000),
    ],
  });

  assert.throws(
    () => containerSizeDiff("fake-from", "fake-to", inspect),
    /Platform sets differ; missing from baseline: linux\/riscv64; missing from current image: linux\/arm64\/v8/,
  );
});

test("the report fails when one of the images cannot be inspected", () => {
  const inspect = fakeInspect({ "fake-from": [platformManifest(amd64, 1000)] });

  assert.throws(
    () => containerSizeDiff("fake-from", "fake-to", inspect),
    /fake: unknown image fake-to/,
  );
});

const missingDiagnostics = [
  "no such manifest: fake-from",
  "manifest unknown",
  "manifest unknown: manifest unknown",
  "manifest unknown: The named manifest is not known to the registry.",
  "MANIFEST_UNKNOWN: manifest unknown",
  "Error response from daemon: manifest unknown: manifest unknown",
];

for (const diagnostic of missingDiagnostics) {
  test(`a missing baseline produces current sizes for: ${diagnostic}`, () => {
    const inspect = fakeInspect({
      "fake-from": inspectionError(`${diagnostic}\n`),
      "fake-to": [
        platformManifest(arm64, 4000),
        platformManifest(amd64, 1000, 1000),
      ],
    });

    const report = containerSizeDiff("fake-from", "fake-to", inspect);

    assert.match(
      report,
      /Comparison unavailable: baseline `fake-from` does not exist\./,
    );
    assert.match(report, /Current image: `fake-to`/);
    assert.match(report, /### 📦 Current Image Sizes/);
    const rows = report.split("\n").filter((line) => line.startsWith("|"));
    assert.match(rows[0], /^\| OS\/Platform +\| Current \|$/);
    assert.match(rows[2], /^\| linux\/amd64 +\| +2 kB +\|$/);
    assert.match(rows[3], /^\| linux\/arm64\/v8 +\| +4 kB +\|$/);
    assert.equal(rows.length, 4);
    assert.doesNotMatch(report, /Previous|Change|Trend|0 B|%|∞|Comparing/);
    assert.throws(() => getSizes("fake-from", inspect), /fake inspection failed/);
  });
}

for (const baselineMissing of [false, true]) {
  test(`a missing current image fails with baseline missing=${baselineMissing}`, () => {
    const currentError = inspectionError("no such manifest: fake-to");
    const inspect = fakeInspect({
      "fake-from": baselineMissing
        ? inspectionError("no such manifest: fake-from")
        : [platformManifest(amd64, 1000)],
      "fake-to": currentError,
    });

    assert.throws(
      () => containerSizeDiff("fake-from", "fake-to", inspect),
      (error) => error === currentError,
    );
  });
}

const fatalDiagnostics = [
  "unauthorized: authentication required",
  "denied: requested access to the resource is denied",
  "forbidden: access denied",
  "dial tcp: lookup registry.example.invalid: no such host",
  "context deadline exceeded",
  "unexpected status from HEAD request: 500 Internal Server Error",
  "unexpected status from HEAD request: 404 Not Found",
  "name unknown: repository name not known to registry",
  "no such manifest: fake-other",
  "manifest unknown: unauthorized",
  "manifest unknown: manifest unknown\nunauthorized: authentication required",
  "no such manifest: fake-from\ncontext deadline exceeded",
];

for (const diagnostic of fatalDiagnostics) {
  test(`baseline inspection errors remain fatal: ${diagnostic}`, () => {
    const baselineError = inspectionError(diagnostic);
    const inspect = fakeInspect({
      "fake-from": baselineError,
      "fake-to": [platformManifest(amd64, 1000)],
    });

    assert.throws(
      () => containerSizeDiff("fake-from", "fake-to", inspect),
      (error) => error === baselineError,
    );
  });
}

for (const properties of [
  { exitCode: 2 },
  { exitCode: undefined },
  { timedOut: true },
  { isCanceled: true },
  { killed: true },
  { signal: "SIGTERM" },
  { stderr: undefined },
]) {
  test(`unconfirmed inspection failures remain fatal: ${JSON.stringify(properties)}`, () => {
    const baselineError = inspectionError(
      "no such manifest: fake-from",
      properties,
    );
    const inspect = fakeInspect({
      "fake-from": baselineError,
      "fake-to": [platformManifest(amd64, 1000)],
    });

    assert.throws(
      () => containerSizeDiff("fake-from", "fake-to", inspect),
      (error) => error === baselineError,
    );
  });
}

for (const invalidManifest of [
  "not JSON",
  [],
  [platformManifest({ os: "unknown", architecture: "unknown" }, 10)],
]) {
  test(`invalid baseline data remains fatal: ${JSON.stringify(invalidManifest)}`, () => {
    const inspect = fakeInspect({
      "fake-from": invalidManifest,
      "fake-to": [platformManifest(amd64, 1000)],
    });

    assert.throws(
      () => containerSizeDiff("fake-from", "fake-to", inspect),
      /Unexpected token|No platform sizes found for fake-from/,
    );
  });

  for (const baselineMissing of [false, true]) {
    test(`invalid current data remains fatal with baseline missing=${baselineMissing}: ${JSON.stringify(invalidManifest)}`, () => {
      const inspect = fakeInspect({
        "fake-from": baselineMissing
          ? inspectionError("no such manifest: fake-from")
          : [platformManifest(amd64, 1000)],
        "fake-to": invalidManifest,
      });

      assert.throws(
        () => containerSizeDiff("fake-from", "fake-to", inspect),
        /Unexpected token|No platform sizes found for fake-to/,
      );
    });
  }
}
