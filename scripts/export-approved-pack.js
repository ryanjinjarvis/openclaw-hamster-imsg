#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

function parseArgs() {
  const args = process.argv.slice(2);
  const options = {};
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    if (!arg.startsWith('--')) continue;
    const key = arg.replace(/^--/, '');
    const value = args[i + 1] && !args[i + 1].startsWith('--') ? args[++i] : 'true';
    options[key] = value;
  }
  return options;
}

function toInt(value, fallback) {
  const parsed = parseInt(value, 10);
  return Number.isNaN(parsed) ? fallback : parsed;
}

function loadJson(filePath) {
  return JSON.parse(fs.readFileSync(filePath, 'utf8'));
}

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function parsePostId(url) {
  if (!url) return null;
  const parts = url.split('/').filter(Boolean);
  return parts[parts.length - 1] || null;
}

function validateManifest(manifest) {
  if (manifest.version !== 'v1') {
    throw new Error(`Manifest version must be v1, received ${manifest.version}`);
  }
  if (!Array.isArray(manifest.items) || manifest.items.length === 0) {
    throw new Error('Manifest must contain at least one item');
  }
  manifest.items.forEach((item, idx) => {
    if (!item.id) throw new Error(`Item ${idx} missing id`);
    if (!item.imageUrl) throw new Error(`Item ${item.id} missing imageUrl`);
    if (!item.thumbnailUrl) throw new Error(`Item ${item.id} missing thumbnailUrl`);
    if (!Array.isArray(item.tags)) throw new Error(`Item ${item.id} tags must be an array`);
    if (item.popularity < 0) throw new Error(`Item ${item.id} popularity must be >= 0`);
    if (!item.source || !item.source.platform || !item.source.account || !item.source.postId) {
      throw new Error(`Item ${item.id} source meta incomplete`);
    }
  });
}

function main() {
  const options = parseArgs();
  const cwd = process.cwd();
  const input = options.input || path.join('apps', 'openclaw-hamster-imsg', 'index', 'index.json');
  const output = options.output || path.join('apps', 'openclaw-hamster-imsg', 'MessagesExtension', 'Resources', 'Manifest', 'exported-manifest.json');
  const limit = toInt(options.limit, 75);
  const minPopularity = toInt(options.minPopularity, 0);
  const data = loadJson(path.resolve(cwd, input));

  const items = (data.items || [])
    .filter((item) => item.status === 'processed')
    .filter((item) => (item.popularity_score || 0) >= minPopularity)
    .sort((a, b) => (b.popularity_score || 0) - (a.popularity_score || 0))
    .slice(0, limit)
    .map((item) => ({
      id: item.item_id,
      imageUrl: item.media_urls?.[0] || item.source_url,
      thumbnailUrl: item.media_urls?.[0] || item.source_url,
      tags: item.labels?.filter(Boolean) || [],
      popularity: Math.max(0, Math.round(item.popularity_score || 0)),
      createdAt: item.created_at || data.generatedAt || new Date().toISOString(),
      source: {
        platform: (data.source?.platform || 'instagram').toLowerCase(),
        account: data.source?.account || 'unknown',
        postId: parsePostId(item.source_url) || item.source_id || item.item_id
      }
    }));

  const manifest = {
    version: 'v1',
    generatedAt: new Date().toISOString(),
    items
  };

  validateManifest(manifest);

  ensureDir(path.dirname(path.resolve(cwd, output)));
  fs.writeFileSync(path.resolve(cwd, output), JSON.stringify(manifest, null, 2));
  console.log(`Manifest exported to ${output} (${manifest.items.length} items)`);

  if (options.seed === 'true' || options.seed === '1') {
    const seedPath = path.join('apps', 'openclaw-hamster-imsg', 'MessagesExtension', 'Resources', 'Manifest', 'hamster_manifest_seed.json');
    fs.writeFileSync(path.resolve(cwd, seedPath), JSON.stringify(manifest, null, 2));
    console.log(`Seed manifest updated at ${seedPath}`);
  }
}

main();
