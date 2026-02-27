# Build & Release Playbook

## 0. Preconditions
- ✅ TestFlight metadata and screenshots prepared (see `TESTFLIGHT_PREFLIGHT.md`).
- ✅ Remote manifest deployed at the URL configured in `AppConfiguration.remoteManifestURL`.
- ✅ `scripts/export-approved-pack.js` executed and bundled seed refreshed if needed.
- ✅ Local machine logged into the correct Apple Developer account.

## 1. Configure signing
1. Open `HamsterIM.xcodeproj`.
2. Select the `HamsterIM` target → Signing & Capabilities:
   - Team: `<YOUR_TEAM_ID>`
   - Bundle Identifier: `dev.openclaw.hamsterim` (or production value)
3. Select the `MessagesExtension` target:
   - Team: same as host app
   - Bundle Identifier: `dev.openclaw.hamsterim.MessagesExtension`
4. Ensure “Automatically manage signing” is enabled, or attach the correct provisioning profiles if using manual signing.

## 2. Update versioning
```text
General > Version: <marketing version, e.g. 1.0>
General > Build: <incrementing build number>
```
Keep host app + extension in sync.

## 3. Verify resources
- Replace placeholder icons under `HamsterIM/Assets.xcassets/AppIcon.appiconset/`.
- Ensure CDN URLs used in manifests are reachable over HTTPS.
- Double-check `MessagesExtension/Resources/Manifest/hamster_manifest_seed.json` matches the CDN manifest (run `node scripts/validate-manifest.js <file>`).

## 4. Build locally
```bash
xcodebuild \
  -scheme HamsterIM \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  clean build
```
Resolve any compiler warnings before continuing.

## 5. Archive & upload
1. Xcode: `Product > Archive` (select `Any iOS Device (arm64)` destination).
2. In Organizer, select the new archive → `Distribute App` → `App Store Connect` → `Upload`.
3. When prompted:
   - Include bitcode: **No** (deprecated).
   - Manage app version/release notes later in App Store Connect.
4. Wait for the “Processing” email from App Store Connect before creating a new TestFlight build.

## 6. Tagging & documentation
- Tag the git commit: `git tag hamster-imsg-v1.0-b42 && git push --tags`.
- Publish release notes referencing the QA + TestFlight checklists.

## 7. Rollback plan
- Keep the previous manifest cached (CDN should allow versioned URLs; avoid overwriting `v1` with breaking schema changes).
- To hotfix, ship a new manifest version without changing the binary unless there is a client-side issue.
