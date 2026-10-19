const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const crypto = require("node:crypto");
const root = path.resolve(__dirname, "..");
const read = p => fs.readFileSync(path.join(root, p));
const map = JSON.parse(read("source-map.json"));
const main = read("main.lua").toString("utf8");
const paths = [...main.matchAll(/"(src\/[^"]+\.lua)"/g)].map(m => m[1]);
assert.deepEqual(paths, map.modules.map(m => m.path), "Manifest order changed");
assert.equal(new Set(paths).size, paths.length, "Duplicate module");
let nextLine = 1;
for (const item of map.modules) {
    assert.equal(item.originalStartLine, nextLine, "Source map has a gap or overlap");
    nextLine = item.originalEndLine + 1;
}
const source = Buffer.concat(paths.map(read));
const sha = crypto.createHash("sha1")
    .update(Buffer.from("blob " + source.length + "\0")).update(source).digest("hex");
assert.equal(sha, map.runtimeBlobSha || map.originalBlobSha, "Feature source differs from the checked-in baseline");
assert.deepEqual(read("blox fruits"), read("loader.lua"), "Legacy entry point diverged");
console.log("PASS: " + paths.length + " modules match the checked-in runtime baseline.");
