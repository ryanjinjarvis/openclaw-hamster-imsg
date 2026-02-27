# TestFlight Preflight Checklist

## App Store Connect prep
- [ ] App record exists with correct bundle ID + platform = iOS.
- [ ] Privacy policy + contact info filled out.
- [ ] Screenshots for 6.5" + 5.5" devices uploaded (Messages extension UI).
- [ ] App Store description references hamster pack + manifest sync behavior.
- [ ] Review notes mention remote CDN dependency + sample manifest URL.

## Build metadata
- [ ] Version/build numbers updated (see BUILD_AND_RELEASE).
- [ ] Export compliance answered (No if only downloading images; update if encryption added).
- [ ] Content rights: confirm assets licensed/owned (Instagram hamster account permission recorded).
- [ ] Age rating questionnaire updated (contains mild cartoon imagery only).

## Tester logistics
- [ ] Internal testers assigned (Design, Eng, Ops) with latest instructions.
- [ ] External tester groups defined + invitation copy ready.
- [ ] Feedback form / Slack channel ready for quick triage.

## Validation artifacts
- [ ] Attach manifest checksum + CDN URL to TestFlight build notes.
- [ ] Upload QA video or screenshots proving send flow works.
- [ ] Store link to exported manifest revision in `memory/` or release tracker.

## Submission gates
- [ ] QA checklist fully passed with evidence.
- [ ] Crash/analytics tools (if any) verified to initialize only in production builds.
- [ ] CDN monitoring alerts configured for manifest availability.
