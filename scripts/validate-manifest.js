#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

if (process.argv.length < 3) {
  console.error('Usage: node validate-manifest.js <manifest-path>');
  process.exit(1);
}

const manifestPath = path.resolve(process.cwd(), process.argv[2]);
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));

if (manifest.version !== 'v1') {
  throw new Error(`Invalid version ${manifest.version}`);
}

if (!Array.isArray(manifest.items) || manifest.items.length === 0) {
  throw new Error('Manifest must include at least one item');
}

manifest.items.forEach((item, idx) => {
  if (!item.id) throw new Error(`Item ${idx} missing id`);
  ['imageUrl', 'thumbnailUrl', 'createdAt'].forEach((key) => {
    if (!item[key]) throw new Error(`Item ${item.id} missing ${key}`);
  });
  if (!Array.isArray(item.tags)) throw new Error(`Item ${item.id} tags must be an array`);
  if (typeof item.popularity !== 'number' || item.popularity < 0) {
    throw new Error(`Item ${item.id} popularity invalid`);
  }
  if (!item.source || !item.source.platform || !item.source.account || !item.source.postId) {
    throw new Error(`Item ${item.id} source incomplete`);
  }
});

console.log(`Manifest ${manifestPath} validated (${manifest.items.length} items)`);
