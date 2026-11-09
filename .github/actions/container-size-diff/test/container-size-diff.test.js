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
    return `${JSON.stringify(images[container])}\n`;
  };
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
