# INSTAGRAM_CRAWL_PLAYBOOK_V1

_Last updated: 2026-02-27 (PST)_

## Goal
Maximize **full-history coverage** for a single **public Instagram account** when browser automation hits pagination/access ceilings, while staying inside normal authenticated access boundaries (no auth bypass, no exploit behavior).

---

## 0) Operating Principles (Hard Constraints)
1. **Use a legitimate logged-in session** and respect Instagram’s access controls.
2. **Do not bypass challenges/captcha/checkpoints programmatically**; resolve manually when required.
3. **Prefer slow, human-like throughput** over burst scraping.
4. **Design for resumability**: every run must be restart-safe.
5. **Use multiple ingestion views** (profile grid, reels tab, tagged, API-like fallback tools) and dedupe downstream.

---

## 1) Session Hygiene (Most Impactful)

### 1.1 Single-consumer session policy
- During crawl windows, avoid concurrent Instagram activity from:
  - mobile app,
  - other browser tabs,
  - parallel bots.
- Why: mixed request consumption increases 429/challenge probability and causes pagination instability.

### 1.2 Stable browser identity
- Reuse the same profile/cookie jar for repeated runs.
- Keep timezone/locale/UA stable.
- Avoid frequent login/logout cycles (challenge trigger).

### 1.3 Session warm-up routine (2–3 min)
Before crawling target:
1. Open instagram.com home.
2. Wait for feed to settle.
3. Visit own profile, then target profile.
4. Only then start extraction.

### 1.4 Checkpoint handling policy
- If checkpoint/challenge appears:
  - pause crawl,
  - solve manually,
  - wait 5–15 min cooldown,
  - resume from last checkpoint.
- If repeated twice in same day: stop and defer to next day.

---

## 2) Pacing & Throughput Control

### 2.1 Adaptive pacing envelope
- Base delay between major actions: **1.5–4.0s random jitter**.
- Every 40–80 posts: add **30–90s micro-break**.
- Every 300–500 posts: add **5–12 min cooldown**.

### 2.2 Backoff ladder on friction
Trigger signals: delayed responses, repeated spinner stalls, partial loads, 429s.
- Step 1: +50% delays for next 50 actions.
- Step 2: pause 10 min and resume.
- Step 3: end run, resume next scheduled window.

### 2.3 Crawl windows
- Prefer 1–3 focused windows/day over continuous 24h crawling.
- Keep each run bounded (e.g., 45–120 minutes).

---

## 3) Navigation Patterns to Push Deeper History

### 3.1 Modal-step strategy (recommended)
Instead of only infinite-scrolling grid:
1. Open first visible post into modal/detail.
2. Advance with next navigation (or close/open sequentially by link list).
3. Capture each post permalink + timestamp + media type.

Why: often more stable than raw page infinite scroll for deep traversal.

### 3.2 Grid-anchor checkpoints
At intervals (e.g., every 100 posts):
- Record anchor tuple: `{permalink, shortcode, timestamp, approximate index}`.
- On resume, navigate directly to nearest known anchor and continue older direction.

### 3.3 Multi-surface traversal order
Run independent passes:
1. **Posts tab**
2. **Reels tab**
3. **Tagged tab** (optional but can fill history gaps)
4. **Pinned posts reconciliation**

### 3.4 Link-first extraction
When possible, prioritize collecting stable post links first, then hydrate metadata/media second pass.
- Pass A: permalink inventory
- Pass B: metadata/media download
This reduces loss from deep-scroll interruptions.

---

## 4) Account-State Tricks (Allowed, Non-bypass)

1. **Manual pre-trust**: spend a few days with normal account behavior before heavy crawl.
2. **Small follows/interactions** (non-spammy) can make account look less throwaway.
3. **Avoid rotating IPs aggressively**. Stable residential-like network is usually more reliable than VPN/proxy churn.
4. **Use logged-in mode whenever possible**; anonymous access tends to be more constrained.

---

## 5) Checkpointing & Data Integrity

## 5.1 Minimum checkpoint schema
Store per discovered post:
- `shortcode`
- `permalink`
- `posted_at`
- `surface` (posts/reels/tagged)
- `discovered_at`
- `run_id`
- `crawl_depth_index`
- `status` (discovered / hydrated / failed)

### 5.2 Resume ledger
Per run, store:
- last successful anchor per surface,
- last request timestamp,
- throttle state,
- error counters,
- checkpoint/challenge events.

### 5.3 Gap detector
After each run:
- sort by `posted_at` descending,
- detect suspicious holes (large time jumps, missing known eras),
- queue targeted recrawls for those windows.

### 5.4 Idempotent writes
Use `shortcode` as unique key to prevent duplicates across reruns/surfaces.

---

## 6) Fallback Ingestion Sources (When Browser Ceiling Hits)

### 6.1 Instaloader (high-value fallback)
Use as secondary ingestion path for public profile history, authenticated with your own valid session.

Practical notes from Instaloader docs/troubleshooting:
- It has built-in rate control and retries for 429.
- Repeated restarts in short intervals can still trigger 429.
- Keep session file and reuse it (reduces login fragility/challenge frequency).
- Logged-in access is generally more reliable than anonymous.

Recommended role:
- Use browser crawler as primary.
- Run Instaloader pass to backfill older posts and compare coverage sets.

### 6.2 Alternate renderer pass
If one browser stack stalls (e.g., Chromium profile issues), run a secondary pass with another clean but stable browser profile and merge unique shortcodes.

### 6.3 Archive/embedded references (limited)
Use only as metadata clues:
- public embeds on blogs/news,
- prior exports already in your dataset.
Do not treat these as authoritative full-history source.

---

## 7) Anti-breakage Monitoring (Keep It Running)

### 7.1 Canary account/profile
Maintain a small, stable public account as a canary target.
- Run a short crawl daily.
- Alert on structural breakage before production runs.

### 7.2 DOM contract tests
Track selectors and structural assumptions:
- profile post grid container,
- post permalink extraction path,
- modal navigation controls,
- reel item discovery.
If any contract fails, stop run early and flag parser update.

### 7.3 Health metrics dashboard
Per run, log:
- discovered posts/hour,
- unique shortcodes,
- duplicate ratio,
- error rate by type,
- average response latency,
- challenge count.
Set alerts on sharp drops (e.g., coverage velocity down >40%).

### 7.4 Regression snapshots
Store occasional HTML snapshots/screenshots at key states:
- initial profile load,
- mid-depth scroll,
- post modal.
Useful for quick parser repair after UI changes.

---

## 8) Ranked Experiments to Run Next (Expected Lift)

> Lift = expected increase in unique historical posts captured vs current baseline run.

### #1 — Two-pass pipeline (link inventory → hydration)
- **Effort:** Medium
- **Expected lift:** **+15% to +35%**
- **Why:** Reduces losses caused by unstable deep session during media/metadata-heavy extraction.

### #2 — Add Instaloader backfill + set reconciliation
- **Effort:** Medium
- **Expected lift:** **+10% to +30%**
- **Why:** Different traversal and request behavior often reaches older posts missed in browser flow.

### #3 — Adaptive throttle with friction signals
- **Effort:** Low-Medium
- **Expected lift:** **+8% to +20%**
- **Why:** Prevents hard stalls/challenges that prematurely end deep crawls.

### #4 — Surface-separated passes (Posts/Reels/Tagged)
- **Effort:** Low
- **Expected lift:** **+5% to +15%**
- **Why:** Reels/tagged often contain items missed by generic profile grid pass.

### #5 — Anchor-based resume and targeted gap recrawls
- **Effort:** Medium
- **Expected lift:** **+5% to +12%**
- **Why:** Converts interrupted runs into cumulative progress; systematically closes timeline holes.

### #6 — Session warm-up + single-consumer enforcement
- **Effort:** Low
- **Expected lift:** **+3% to +10%**
- **Why:** Reduces instability from mixed activity and abrupt cold-start behavior.

---

## 9) Suggested Runbook (Next 7 Days)

### Day 1–2
- Implement checkpoint schema + unique-key dedupe.
- Add adaptive throttle and friction backoff.

### Day 3–4
- Switch to two-pass architecture.
- Start anchor checkpoints every 100 discoveries.

### Day 5
- Run Instaloader backfill (authenticated, session-file reuse).
- Reconcile shortcodes against browser dataset.

### Day 6
- Execute targeted gap recrawls by missing date windows.

### Day 7
- Review metrics; lock best-performing pacing/window profile.
- Promote successful experiment settings to default config.

---

## 10) Coverage Scoring Model (Simple)
Track progress with:

`coverage_score = unique_shortcodes_collected / estimated_total_posts`

Where `estimated_total_posts` can be approximated from:
- visible profile counts (when reliable),
- historical baseline max,
- merged union after multiple methods.

Also track:
- `oldest_post_timestamp_reached`
- `% runs reaching oldest_known_year`
- `gap_count_per_12_months`

---

## 11) Practical Stop Conditions
Stop a run when any condition is true:
- 2+ checkpoint/challenge prompts in one session,
- repeated 429 despite cooldown/backoff,
- no new unique posts after N scroll/modal steps (e.g., 300 actions),
- parser contract failure on critical selector.

Then resume next window using last anchor checkpoint.

---

## Appendix A — Compliance Notes
- This playbook is for **authorized access to public account data** with a valid user session.
- No credential stuffing, no CAPTCHA bypass, no private-account circumvention, no exploit steps.
- Respect platform terms and local laws; obtain legal review for production/commercial use.
