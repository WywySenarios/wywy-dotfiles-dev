# Adversary Report — Shared Rubric & Format

This is the shared specification for adversary reports. It is loaded into every
agent's context so that all agents know what an adversary report looks like and
can read, produce, or interpret one. The adversary agents (`plan-adversary`,
`adversary`) and the `code-reviewer` agent follow this exactly; every other agent
can rely on reports matching this format.

## Severity & Priority Scale

All issues found by an adversary agent must be classified with both a severity and a priority.

### Severity: SEV-1 through SEV-5

| Level | Label        | Definition                                                      |
| ----- | ------------ | --------------------------------------------------------------- |
| SEV-1 | **Critical** | Causes data loss, corruption, security breach, or total outage. |
| SEV-2 | **High**     | Major feature broken, no acceptable workaround.                 |
| SEV-3 | **Medium**   | Feature partially broken, has a workaround.                     |
| SEV-4 | **Low**      | Minor issue, cosmetic, or non-functional defect.                |
| SEV-5 | **Cosmetic** | Nitpick: style, naming, documentation typo, minor polish.       |

An individual agent may add anchors specific to its review target (e.g. plan-text defects, speculative risks). They extend this table; they do not replace it.

### Severity anchors for plan-outcome reviews

Plan-outcome reviews (the `adversary` agent, `plan-outcome-review` mode) extend the severity table with these anchors:

- an **unimplemented plan property** — the plan asserts behavior and there is no production code and no passing test proving it — is **SEV-2**
- a **misasserted test** — a test exists but does not prove the plan's claimed behavior (weak, tautological, or wrong assertions) — is **SEV-3**
- a **speculative risk** — a hypothetical concern not evidenced by the plan or the repository — is **SEV-5** at most

### Severity anchors for plan reviews

Plan reviews (the `plan-adversary` agent) extend the severity table with these anchors:

- a **loud transcription defect** — a plan-text error (typo, wrong name, stale path) that contradicts the repository on contact (nonexistent path, unresolvable symbol) and would be caught by the executor within seconds — is **SEV-4**, **P1**, and triggers `Revise` but never `Block`. Loud transcription defects are **mechanically fixable**: the Suggested Action carries the corrected value, and the fix is verified by resolving the reference against the repository — no re-audit is required when they are the only findings (a _transcription-only_ revision).
- a **silent wrong-target defect** — a plan-text error that is internally coherent but resolves to a different existing target and would execute without error against the wrong file, symbol, or data — receives **full severity by real outcome** (SEV-1 when it could cause data loss, corruption, a security breach, or total outage)
- an **out-of-scope finding** — a concern the plan's `Target State` does not require, or that its `Non-Goals` explicitly excludes — is **SEV-5**, **P3**, and **advisory**: it never counts toward the verdict. Record it under "Advisory / Out-of-Scope", not in the Issues table.
- a **scope-expansion defect** — a plan phase, dependency, or artifact not traceable to the `Target State`, or a Suggested Action that would require new scope without user approval — is **SEV-2**, **P1**. The defect is the growth, not the missing capability.
- a **speculative risk** — a hypothetical concern not evidenced by the plan or the repository — is **SEV-5** at most and advisory

### Severity anchors for diff reviews

Diff reviews (the `code-reviewer` agent) extend the severity table with these anchors:

- an **unjustified dependency change** — a manifest or lockfile change with no traceable reason in the diff — is **SEV-3**, **P1**
- a **multi-purpose commit** — a commit whose purpose cannot be stated in one sentence without an "and" (unrelated changes, behavior mixed with refactor, unpaired lockfile churn) — is **SEV-3**, **P1**: an overwhelming diff is a reviewability defect, not a stylistic nit
- an **unsafe, vulnerable, or unpinned dependency** — receives **full severity by real outcome** (SEV-1 when it exposes a supply-chain or exploit path)
- a **misasserted test** — a new or changed test whose assertion cannot fail on the claimed regression (tautological, over-mocked, or asserting the wrong thing) — is **SEV-3**, **P1**
- a **false comment or doc claim** — a comment or docstring that disagrees with the code — is **SEV-2**, **P1** when it can mislead a caller into unsafe use; otherwise **SEV-3**
- an **untouched pre-existing defect** — a problem visible in the surrounding code but not introduced, worsened, or made reachable by the diff — is **SEV-5**, **P3**, and advisory

### Priority: P0 through P3

| Level | Label         | Definition                                                     |
| ----- | ------------- | -------------------------------------------------------------- |
| P0    | **Immediate** | Must be fixed before anything else — blocks all progress.      |
| P1    | **High**      | Should be fixed in this cycle/PR — important but not blocking. |
| P2    | **Medium**    | Fix when convenient — can be deferred without major risk.      |
| P3    | **Low**       | Nice-to-have — address if time permits.                        |

## Holistic Score

The holistic score is an **objective, issue-derived health score** from 0.0 to 10.0. It measures the _materiality_ of the defects found, not the verdict. A clean target with no issues scores 10.0. The score informs the verdict and can force `Revise`, but it never forces `Block`.

### Computation

Start at **10.0**. Apply deductions:

1. **Group issues by root cause.** If multiple issues share one root cause, group them and apply the single worst penalty of the group once. Do not double-count.
2. **Deduct the larger of the severity penalty and the priority penalty — never both.** Severity and priority measure the same "how bad is this" dimension; charging both inflates the damage.
3. **Cap non-blocking noise.** The combined deduction from issues that are **SEV-4/SEV-5 and P2/P3** (cosmetic/low nits that do not block `Pass`) is capped at **-1.0** total. A pile of nits can never drag a target below "Fair".
4. Floor the result at **0.0**.

Penalty table (single deduction = max of the two rows):

| Severity | Penalty | Priority | Penalty |
| -------- | ------- | -------- | ------- |
| SEV-1    | -3.0    | P0       | -1.5    |
| SEV-2    | -2.0    | P1       | -1.0    |
| SEV-3    | -1.0    | P2       | -0.5    |
| SEV-4    | -0.4    | P3       | -0.2    |
| SEV-5    | -0.2    |          |         |

Example: a single SEV-2/P1 issue deducts `max(-2.0, -1.0)` = **-2.0**, not -3.0. A SEV-5/P3 nit deducts `max(-0.2, -0.2)` = **-0.2**. Five SEV-5 nits deduct **-0.2 × 5 = -1.0**, floored by the cap, never more.

### Score interpretation

| Range | Label        | Meaning                                           |
| ----- | ------------ | ------------------------------------------------- |
| 9-10  | **Healthy**  | No material issues. Ship with confidence.         |
| 7-8.9 | **Fair**     | Minor issues. Fix before shipping.                |
| 4-6.9 | **Risky**    | Significant issues. Must resolve before proceed.  |
| 1-3.9 | **Broken**   | Major defects. Do not proceed without a redesign. |
| 0     | **Redesign** | Redesign required.                                |

The **score is a verdict input, not the whole verdict**. A 0.0 score does not imply `Block`: `Block` requires a SEV-1 issue. A score below 7.0 forces `Revise` even when no single severe issue dominates; a score of 7.0 or higher still yields `Revise` when a SEV-2 or P0 issue is present.

### Verdict thresholds

The verdict is derived deterministically from the issues found (severity and priority) and the score. Apply the first matching row from top to bottom:

| Verdict    | Trigger                                                                                                                     |
| ---------- | --------------------------------------------------------------------------------------------------------------------------- |
| **Block**  | Any SEV-1 issue.                                                                                                            |
| **Revise** | Any SEV-2, any P0, any silent wrong-target defect, any loud transcription defect (SEV-4/P1), or a holistic score below 7.0. |
| **Pass**   | No SEV-1/2 issues, no P0 issues, no wrong-target or transcription defects, and a holistic score of 7.0 or higher.           |

SEV-3/4/5 and P1/P2/P3 findings do not trigger `Revise` on their own, but they
count toward the score, and enough of them can push it below 7.0. The exceptions are
silent wrong-target and loud transcription defects, which force `Revise` even below
SEV-2 (SEV-1 still means `Block`). Out-of-scope findings never count toward the verdict.

The review target is not ready until the verdict is **Pass**. A `Revise` report must
list exactly what must change to reach `Pass`; a `Block` report ends the audit.
Out-of-scope items are not required to reach `Pass`.

## Report file

Every review report is **persisted to disk** so the history of verdicts, scores, and issues is queryable over time. Write the report to: `<plan-storage>/adversary/<report-name>.md`, where `<plan-storage>` is the `$PLAN_STORAGE_PATH` environment variable (default: `$HOME/plans/`).

The `adversary/` subdirectory is the **default and only** report location. Create it if it does not exist. Do **not** write reports to the top level of `<plan-storage>` (e.g. `$HOME/plans/`) or to the reviewed plan's own directory — those are reserved for plans themselves.

### Report naming by mode

- `mode: plan-review` → `<plan-name>.md`
- `mode: code-review` → `<input-base>-<YYYY-MM-DD>.md` (the input's basename without extension, date-stamped; no "adversary" or "code-review" in the filename)
- `mode: diff-review` → `<review-label>-<YYYY-MM-DD>.md` (the branch name or short commit sha, date-stamped; never the plan name, which leaks intent into a blind review)
- `mode: plan-outcome-review` → `<plan-name>-<YYYY-MM-DD>.md` (the reviewed plan's basename without extension, date-stamped; distinct from the plan-review report at `<plan-name>.md`)

### Frontmatter

Reports must have a YAML frontmatter.

```yaml
timestamp: <ISO-8601 with timezone>
mode: plan-review | code-review | diff-review | plan-outcome-review
input: <name or path of what was reviewed>
verdict: pass | revise | block
holistic_score: <X.X out of 10.0>
issue_count: <N>
advisory_count: <N>
sev1_count: <N>
sev2_count: <N>
sev3_count: <N>
sev4_count: <N>
sev5_count: <N>
p0_count: <N>
p1_count: <N>
p2_count: <N>
p3_count: <N>
invoked_by: <agent_name> | user
```

## Report Body

The full report content goes after the frontmatter.

## Report discipline

- **At most 8 issues**, listed **highest severity first** (ties: highest priority first). Drop or merge findings beyond the 8 most material.
- **At most 5 advisory items.** Advisory items do not consume the 8-issue budget and never affect the verdict.
- **Description cells ≤ 200 characters.** Move detail to the corresponding failure-proof row.
- **One finding, once.** Each finding appears in the Issues table; the failure proof gives evidence; the Summary states the bottom line. Do not restate a finding's full description in more than one section.
- **One Suggested Action per issue**, highest severity first. Do not restate the issue description in the action. Each action is the **minimal change** that resolves the finding and does not bundle unrelated improvements or propose work the target does not need.

### Unified report body template

```md
### Issues Found

| #   | Target     | Severity | Priority | Description          |
| --- | ---------- | -------- | -------- | -------------------- |
| 1   | `<target>` | SEV-2    | P1       | `<what, where, why>` |

`<target>` is a cycle/phase for plan reviews; a `file:line` for code/design reviews; a `file:line` or `<dependency>` for diff reviews; a `file:line` (code issues) or `<cycle>/<property>` (fulfillment gaps) for plan-outcome reviews.

### Failure proofs

| #   | Proof type | Location     | Detail                             |
| --- | ---------- | ------------ | ---------------------------------- |
| 1   | Static     | `file:line`  | `This will crash when X because Y` |
| 2   | Test       | `test suite` | `Running tests shows Z fails`      |

### Holistic Score

**Score:** `<X.X/10>` — `<Label>`

### Summary

<2-4 sentences. Sentence 1: verdict and score. Sentence 2: what must change. Sentence 3: what is acceptable as-is. Lead with the bottom line.>

### Suggested Actions

1. <one action per issue, highest severity first>

### Advisory / Out-of-Scope

| #   | Target     | Description                                   |
| --- | ---------- | --------------------------------------------- |
| 1   | `<target>` | `<concern the plan does not need to address>` |

Advisory items never affect the verdict. Omit the section when there are none.
```

## Conversational Output

When the report is delivered in-chat rather than persisted, use this variant:

```md
## ADVERSARY REPORT

**Target:** `<plan-name or file(s)/area>`

**Verdict:** `Pass` | `Revise` | `Block`

### Issues Found

| #   | Target     | Severity | Priority | Description          |
| --- | ---------- | -------- | -------- | -------------------- |
| 1   | `<target>` | SEV-2    | P1       | `<what, where, why>` |

### Failure proofs

| #   | Proof type | Location     | Detail                             |
| --- | ---------- | ------------ | ---------------------------------- |
| 1   | Static     | `file:line`  | `This will crash when X because Y` |
| 2   | Test       | `test suite` | `Running tests shows Z fails`      |

### Holistic Score

**Score:** `<X.X/10>` — `<Label>`

### Summary

<2-4 sentences. Sentence 1: verdict and score. Sentence 2: what must change. Sentence 3: what is acceptable as-is. Lead with the bottom line.>

### Suggested Actions

1. <one action per issue, highest severity first>

### Advisory / Out-of-Scope

| #   | Target     | Description                                   |
| --- | ---------- | --------------------------------------------- |
| 1   | `<target>` | `<concern the plan does not need to address>` |

Advisory items never affect the verdict. Omit the section when there are none.
```
