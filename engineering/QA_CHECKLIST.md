# QA Checklist – Hamster iMessage App

## Smoke & Manifest Sync
- [ ] Launch Messages extension – verify grid renders ≥1 hamster from bundled seed.
- [ ] Trigger remote sync (kill & relaunch with network on) – confirm status label updates to `Synced ...`.
- [ ] Disconnect network, relaunch – ensure offline banner shows and cached data still loads.
- [ ] Corrupt remote manifest (serve invalid JSON) – client should fall back to cache + surface "Invalid manifest" message.

## Search Experience
- [ ] Typing a tag substring filters results in real time.
- [ ] Clearing search restores full grid without jitter.
- [ ] Searching for unknown text shows empty grid but no crashes.

## Popularity Sorting
- [ ] Items are ordered desc by `popularity` (verify via manifest sample values).
- [ ] When `popularity` ties, the newer `createdAt` item appears first.

## Message Insertion
- [ ] Tap cell inserts hamster into active conversation with correct caption.
- [ ] Rapidly tap multiple cells – ensure duplicates respect tap order, no crashes.
- [ ] If network image download fails, toast reports `Failed to load image`.

## Accessibility & UX
- [ ] VoiceOver reads cell tag text and "button" trait.
- [ ] Dynamic type: increase font size → labels remain legible and layout stays intact.
- [ ] Light/Dark mode – backgrounds + text remain accessible.

## Regression Pass
- [ ] Host container app launches and explains entry point.
- [ ] Launch screen uses production app icon.
- [ ] Validate manifests bundled with build via `node scripts/validate-manifest.js`.
