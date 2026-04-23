# Aura Coach AI — Codebase Audit (Release Readiness) — Design Spec

**Date:** 2026-04-18
**Status:** APPROVED (brainstorming)
**Owner:** Luu
**Audit driver:** Pre-release readiness
**Audit mode:** Report only (no code fixes in this flow)
**Deliverable format:** Gap analysis style (mirroring `docs/design-system-gap-analysis.md`)
**Scope:** Flat 16-category deep-dive over `lib/` (~113 Dart files, ~18k LOC) and project config

---

## 1. Goals

1. Produce a reproducible, reviewable gap analysis of the codebase against 16 categories defined by the user.
2. Surface every release-blocking issue (CRITICAL severity) before production deploy.
3. Give equal methodological treatment to all 16 categories so the output is symmetric and comparable.
4. Keep the document self-contained — a future reader should understand the methodology, taxonomy, and findings without reading this spec.

## 2. Non-goals

- Do not implement fixes in this flow (user chose "Report only").
- Do not audit backend Firestore Cloud Functions or services outside the repo.
- Do not perform runtime penetration testing, load testing, or device-farm testing.
- Do not deep-dive native Android/iOS code beyond config files (`build.gradle`, `Info.plist`, `AndroidManifest.xml`).
- Do not lint individual ARB strings for localization completeness; only check infra.
- Do not create GitHub issues, Linear tickets, or Notion pages automatically.
- Do not write a remediation plan per finding (just 1–3 line Remediation text).

## 3. Approach — Flat 16-category deep-dive (Approach B)

All 16 categories receive the same 4-step methodology regardless of expected yield. Categories that naturally produce few findings (e.g., CI/CD on a repo without pipelines) still follow the full template so *absences* become explicit findings. Symmetric process ≠ symmetric volume.

### 3.1 Per-category methodology (4 steps)

**Step 1 — Inputs.** List the files, config, and cross-referenced docs audited for this category.
- Code files: `lib/**` filtered by category concern (e.g. Lifecycle → every `StatefulWidget` / `ChangeNotifier` / `StreamSubscription`).
- Config files: `pubspec.yaml`, `analysis_options.yaml`, `firebase.json`, `firestore.rules`, `.env`, `l10n.yaml`, `android/**`, `ios/**` config only.
- Docs cross-reference: `docs/business-flow/*`, `docs/superpowers/specs/*`, `docs/superpowers/plans/*`.

**Step 2 — Automated scan.** Run category-specific tools and grep heuristics.
- Static analysis: `flutter analyze --no-fatal-infos`, outputs bucketed per category.
- Grep patterns (examples):
  - Security → `print(`, `log(`, hardcoded URLs/keys, token in `SharedPreferences`.
  - Lifecycle → `StreamSubscription` without `cancel`, `AnimationController` without `dispose`, `Timer` without `cancel`.
  - Performance → `setState` inside `build`, missing `const`, unbounded `ListView`.
- Dependency tools: `dart pub outdated`, `dart pub deps`.
- Test tools (for Testing category only): `flutter test --coverage`.

**Step 3 — Manual review.** Read ~5–10 representative files per category for pattern-level judgment that tools miss.
- Architecture → `lib/app.dart`, router, provider DI graph, repo wiring.
- Business logic → one end-to-end flow (onboarding complete, or scenario chat).
- State flow → `ChangeNotifier` + listener pattern, mutability, sync points.

**Step 4 — Findings synthesis.** Convert issues to finding records using the schema in Section 4.

### 3.2 Baseline freeze

Audit runs against a single commit SHA recorded in the output metadata. Working tree currently has uncommitted changes on `master`. Before execution, user must choose:

- **(a) Preferred — commit/stash uncommitted changes**, then audit HEAD commit. File:line references stay valid.
- **(b) Acceptable — audit HEAD ignoring uncommitted diff**, with explicit note in metadata. Line numbers may drift after the pending commit lands.

This decision is deferred to execution-plan phase, not this spec.

## 4. Finding record schema

Every finding must have the following fields. No exceptions.

```
FINDING-{NN}: {short title, ≤80 chars}
- Category: {1–16}
- Severity: CRITICAL | HIGH | MEDIUM | LOW
- Gap type: {one of enum below}
- Location: {file:line} — multiple lines allowed, bullet list if >3
- Evidence: {code snippet or tool output, fenced block ≤15 lines}
- Impact: {1–2 lines — what breaks for user or release}
- Remediation: {1–3 lines — how to fix; do NOT write code}
- Effort: XS | S | M | L   (XS <1h, S 1–4h, M 4–16h, L >16h)
- Status: OPEN
```

### 4.1 Severity rubric (pre-release lens)

- **CRITICAL** — ship blocker. Examples: secret key in repo, no crash reporting wired, auth token in `SharedPreferences`, missing error handling on payment/auth API, business-logic bug corrupting user data.
- **HIGH** — ship possible but incident likely within first weeks. Examples: dispose leak, no retry/timeout on network, permissive Firestore rules, missing offline fallback for core flow.
- **MEDIUM** — tech debt to resolve next release. Examples: widget rebuild hotspot, naming inconsistency, deps >1 major behind.
- **LOW** — polish. Examples: dead code, redundant comments, minor folder restructure opportunity.

### 4.2 Gap type enum

| Value | Meaning |
|-------|---------|
| `MISSING` | Feature, safety net, or infra does not exist |
| `IMPLEMENTED_NOT_USED` | Code exists but has no callers |
| `INCONSISTENT` | Same concern implemented multiple ways |
| `ANTI_PATTERN` | Wrong pattern (e.g. `setState` after `dispose`) |
| `LEAK` | Resource not released |
| `UNSAFE` | Security or privacy concern |
| `OUTDATED` | Dep/API retired or deprecated |
| `UNCOVERED` | Missing test coverage on critical flow |

### 4.3 Coverage dashboard schema

One row per category. Columns:

| # | Category | Findings | CRITICAL | HIGH | MEDIUM | LOW | Release Risk | Notes |

`Release Risk` derived:
- `HIGH` if ≥1 CRITICAL
- `MEDIUM` if 0 CRITICAL and ≥1 HIGH
- `LOW` if 0 CRITICAL and 0 HIGH (only MEDIUM/LOW findings)

## 5. Per-category section template

Each of the 16 categories renders identically in the output file:

```markdown
## Category N — {Name} — {Status emoji}

**Scope:** {1–2 lines — what this category covers in THIS codebase}

**Inputs audited:**
- Files: {list or glob}
- Tools run: {e.g. `flutter analyze`, `grep 'StreamSubscription'`}
- Docs cross-referenced: {list}

**Sub-items matrix:**

| Sub-item | Standard expected | Code status | Gap type | Severity |
|----------|-------------------|-------------|----------|----------|
| {user-listed sub-items verbatim} | ... | ... | ... | ... |

**Findings:**

### FINDING-{NN}: ...
(schema from Section 4)

**Category summary:** {1–2 lines — OK / NEEDS_WORK / BLOCKING_RELEASE}
```

### 5.1 Sub-items source

Sub-items are taken **verbatim** from the user's checklist — no inventing extras, no omitting. For each category:

| # | Category | Sub-items |
|---|----------|-----------|
| 1 | Architecture & Design | Layer separation, Dependency flow, State management consistency, Modularity / feature structure |
| 2 | Code Quality | Clean code, Naming convention, SOLID / DRY, Dead code |
| 3 | Performance | FPS / jank, Widget rebuild, Memory usage, Image optimization, Lazy loading |
| 4 | Lifecycle & Resource | Dispose controller, Stream / timer management, App lifecycle handling |
| 5 | Network & API | API abstraction, Error handling, Retry / timeout, Offline handling |
| 6 | Security | Token storage, Sensitive data logging, Obfuscation, Certificate pinning |
| 7 | Testing | Unit test, Widget test, Integration test, Coverage |
| 8 | Dependency Management | Outdated packages, Version conflict, Unused packages |
| 9 | CI/CD | Build pipeline, Environment config, Versioning, Automation |
| 10 | UI/UX | Design consistency, Responsive, Accessibility, Dark mode |
| 11 | Logging & Monitoring | Crash tracking, Analytics, Log level |
| 12 | State & Data Flow | Single source of truth, Immutable state, Sync data |
| 13 | Business Logic | Flow correctness, Edge cases, Error scenarios |
| 14 | Offline Capability | Cache, Sync, Conflict handling |
| 15 | Platform Integration | Permissions, Native SDK, Deep link |
| 16 | Maintainability | Folder structure, Documentation, Readability |

### 5.2 Status emoji

- `✅ OK` — no CRITICAL, no HIGH
- `⚠️ NEEDS_WORK` — has HIGH, no CRITICAL
- `🔴 BLOCKING_RELEASE` — ≥1 CRITICAL
- `➖ N/A` — category does not apply (rare; e.g. deep-link sub-item if project has none)

### 5.3 Cross-category finding handling (deduplication)

When a finding touches **2 or more categories** (e.g. missing `dispose` = Lifecycle + Performance):
- Primary record lives in the most-fitting "owner" category.
- Every other affected category adds one line in its Findings section: `See FINDING-NN in Category X — cross-cutting concern`.
- The full record is never duplicated.

This is purely a deduplication convention. Separately, Section 6 of the output file aggregates *systemic* cross-cutting patterns (findings touching 3+ categories) so the reader can spot themes.

### 5.4 Low-yield categories

If a category surfaces ≤2 findings:
- Sub-items matrix still lists all sub-items from Section 5.1.
- Sub-items genuinely inapplicable get row value `N/A — {reason}`.
- Findings may be a single record (e.g. `FINDING-NN: {Category} — no dedicated infrastructure`).
- Template is never compressed or shortened.

## 6. Deliverable file structure

**Location:** `docs/audit/2026-04-18-codebase-audit-release-readiness.md`

**New folder rationale.** Creating `docs/audit/` (sibling of `docs/business-flow/`, `docs/mockup-design/`, `docs/superpowers/`) keeps audits — point-in-time findings snapshots — separate from design specs (the "what") and execution plans (the "how"). Future audits (security-only, post-release, etc.) can live alongside.

**Naming convention:** `YYYY-MM-DD-codebase-audit-{scope}.md`. This instance: `release-readiness`.

**Top-level outline of the output file:**

```
0. Metadata block
   - Date, last updated, audit type, auditor, sources audited, tools used
   - Commit SHA (baseline freeze)

1. Executive Summary (≤1 page)
   - Overall verdict: READY / NEEDS_WORK / NOT_READY_FOR_RELEASE
   - Top 5 release blockers with pointers to FINDING-NN
   - Totals: findings by severity, categories blocking release

2. Coverage Dashboard (16-row table, Section 4.3 schema)

3. Release Blockers
   - All CRITICAL findings aggregated, in category order
   - Copy/paste records — no rewriting

4. Category Deep-Dives (16 sections, Section 5 template)
   Order: as listed by user (1 → 16) in the final document.
   Execution order (Section 7) differs for efficiency but final rendering follows user-listed order.

5. Cross-Cutting Concerns
   - Systemic patterns: findings whose root cause affects ≥3 categories
   - Purpose: surface themes (e.g. "observability missing everywhere") rather than repeat individual finding records

6. Appendix A — Tooling commands used (reproducibility)

7. Appendix B — Out-of-scope (explicit)
   - Runtime penetration testing
   - Load/stress testing
   - Native Android/iOS code beyond config files
   - Backend Firestore/Cloud Functions code
   - Screen-reader-based accessibility audit
   - Localization string completeness
   - Device-farm testing

8. Appendix C — Glossary (severity, gap type, emoji)
```

## 7. Execution plan

### 7.1 Execution order (by dependency, not by user-list order)

Rendered order in the file follows user-list (1–16). Execution order below is chosen so upstream categories inform downstream ones:

**Phase A — Foundation (3)**
1. Architecture & Design
2. Dependency Management
3. Maintainability

**Phase B — Code correctness (4)**
4. Code Quality
5. State & Data Flow
6. Business Logic
7. Lifecycle & Resource

**Phase C — Runtime behavior (3)**
8. Performance
9. Network & API
10. Offline Capability

**Phase D — Production readiness (4)**
11. Security
12. Logging & Monitoring
13. Testing
14. CI/CD

**Phase E — Surface (2)**
15. UI/UX
16. Platform Integration

### 7.2 Time budget

Guideline per category: 20–40 min. No hard cap. Early categories (Architecture, State) are expected longer due to cross-file reading; late categories (CI/CD, Platform Integration) shorter due to small surface area.

### 7.3 Review checkpoints

- **Checkpoint 1** — after Phase A (3 categories): user samples output to align on detail level and finding language.
- **Checkpoint 2** — after Phase C (10 categories cumulative): mid-way review.
- **Checkpoint 3** — final review after all 16 categories + Executive Summary + cross-cutting section.

### 7.4 Commit strategy

- After Phase A: partial commit of output file.
- After Phase C: mid-progress commit.
- Final: complete commit.
- Message format: `docs(audit): <phase> — <N> categories complete`

### 7.5 Verification (mandatory before final handoff)

- Re-read complete output file: schema compliance for every finding, no placeholders, cross-references valid.
- Reconcile numbers: Executive Summary totals == Coverage Dashboard sums == sum across category sections.
- Re-run `flutter analyze` and diff against recorded findings to ensure no miss.

## 8. Acceptance criteria

The audit is considered complete when all of the following are true:

1. Output file exists at `docs/audit/2026-04-18-codebase-audit-release-readiness.md` and is committed.
2. All 16 categories have the full section template filled (scope, inputs, sub-items matrix with all user-listed sub-items, findings — possibly empty, summary).
3. Coverage Dashboard has 16 rows with populated severity counts.
4. Every CRITICAL finding appears once in Section 3 (Release Blockers) and once in its owning Category Deep-Dive.
5. Executive Summary verdict is one of: READY / NEEDS_WORK / NOT_READY_FOR_RELEASE.
6. Appendices A, B, C are present and non-empty.
7. `flutter analyze` was run at least once during the audit and its output reconciled with findings.
8. Metadata block records the commit SHA audited against.

## 9. Open decisions (must resolve before execution begins)

1. **Baseline freeze** — option (a) commit pending changes first, or (b) audit dirty tree with note in metadata. Section 3.2.
2. Whether to generate any machine-readable artifact (e.g. `findings.json`) alongside the Markdown file — currently out of scope, add only if user requests.

## 10. Risks

- **Drift between audit and codebase.** Mitigated by baseline freeze (Section 3.2) and commit SHA in metadata.
- **False negatives from tool-only scans.** Mitigated by mandatory manual review (Step 3 of methodology).
- **Scope creep from cross-cutting findings.** Mitigated by single-owner convention (Section 5.3).
- **User checkpoint fatigue.** Mitigated by explicit 3-checkpoint cap (Section 7.3).
