# EXECUTION_BOARD_V1.md

Project: OpenClaw Hamster iMessage
Release path: TestFlight -> App Store
Content updates: Remote releases
UX: Search bar + popularity-sorted grid

## Track Owners
- Product/Manager
- iOS Engineer
- Data/Backend Engineer
- QA Engineer

---

## Sprint 1 (Core App Skeleton)

### Product/Manager
- [ ] Finalize v1 UX spec (search + grid only)
- [ ] Define v1 success metrics (search latency, insert success rate)

### iOS Engineer
- [ ] Create iMessage App Extension scaffold
- [ ] Build search bar + grid UI
- [ ] Implement popularity sort in UI layer
- [ ] Implement image insert into active conversation

### Data/Backend Engineer
- [ ] Define `hamsters.json` schema (id, tags, popularity, image_url, version)
- [ ] Build local sample dataset from approved hamster pack
- [ ] Add data loader in app (local JSON)

### QA Engineer
- [ ] Smoke tests: open app, search, render, insert
- [ ] Device/simulator compatibility matrix

Deliverable: working local iMessage app demo (no remote sync yet)

---

## Sprint 2 (Remote Content Releases)

### Product/Manager
- [ ] Define remote release cadence + rollback policy
- [ ] Define cache/update UX behavior

### iOS Engineer
- [ ] Add remote manifest fetch
- [ ] Add local cache + version check
- [ ] Add graceful offline fallback

### Data/Backend Engineer
- [ ] Publish manifest endpoint + image hosting strategy
- [ ] Add daily pipeline export from hamster master DB -> manifest bundle
- [ ] Add signed/versioned release artifacts

### QA Engineer
- [ ] Test version upgrade path
- [ ] Test stale cache / corrupted manifest recovery

Deliverable: app updates hamster content remotely without binary update

---

## Sprint 3 (Release Hardening)

### Product/Manager
- [ ] Prepare TestFlight notes + rollout plan
- [ ] Prepare App Store metadata/checklist

### iOS Engineer
- [ ] Crash/perf pass
- [ ] Polish search and grid responsiveness
- [ ] Finalize app icons/splash/basic branding

### Data/Backend Engineer
- [ ] Monitoring for manifest/image delivery
- [ ] Alerting for broken assets

### QA Engineer
- [ ] Full regression pass
- [ ] TestFlight bug triage loop

Deliverable: TestFlight build ready + App Store submission package

---

## Engineering Gates
- Must pass: search works, grid renders, insert works
- Must pass: remote manifest rollback tested
- Must pass: duplicate-image prevention in daily pipeline
- Must pass: no obvious non-hamster leakage in released feed

## Today’s First 5 Tasks
1. Create iMessage extension scaffold
2. Define `hamsters.json` schema
3. Build local loader + popularity sort
4. Wire search bar to filtering
5. Demo insert action end-to-end
