> **Provenance.** This is the original design brief for `developer-plenger/skills`, written in Indonesian, and it is the input the pack was built from. It is filed here for the reasoning behind the design, not as documentation: it is **not a contract**, and where it disagrees with the shipped pack, `docs/architecture.md` and the skills' `references/` are authoritative.
>
> Known divergences from the implementation, all verified against the text below. (1) Task state: section 10 presents the three flags as a YAML block (`implemented: false`, `reviewed: false`, `tested: false`), while the pack carries them as the markdown checkboxes the brief's own section 9 already shows (`- [ ] Implemented` and so on) and forbids a `status:` field. The brief is internally inconsistent here; the pack follows its section 9. (2) `fix` is described in section 16 as optional and outside the core skill set; in the pack `/fix` is required, with its own skill directory, reference file and `templates/FIX.md`. (3) The `AGENTS.md` sketch in section 4 registers five skills (PLAN, SLICE, EXEC, REVIEW, CHECK) and omits `INIT`; the pack registers all seven, `INIT` first. (4) The brief contradicts itself on the EXEC/REVIEW/CHECK ordering. Section 1's diagram draws `EXEC -> REVIEW -> CHECK` as a chain, and section 15's sequential example orders `exec -> review -> fix -> review -> check`; against those, section 15's own prose states the sibling rule ('exec -> review' and 'exec -> check', never 'exec -> review -> check') and section 16's Flow diagram draws those same siblings ahead of `FIX`. The brief disagrees with itself across those three places. The pack takes the sibling reading, and after a fix re-runs both `/review` and `/check` — where section 15's example re-runs review before a single trailing check, and section 16's Flow does not return to check at all. Section 1's separate advice that CHECK runs per finished slice or phase rather than per task does match the pack. (5) The folder trees in sections 2 and 17 list six templates (`AGENTS.md` through `CHECK.md`) and three docs (`workflow.md`, `architecture.md`, `state-machine.md`); the pack ships seven templates and four docs, the additions being `templates/FIX.md` and this brief itself. (6) Section 4 fixes its phase list at five numbered steps (PLAN through CHECK); the pack's chain is seven names, `INIT` and `FIX` included.
>
> The headings, section numbers and wording below are unchanged from the brief as received. Edit it only to correct the record, never to bring it in line with the pack — the divergences above are where its value lies.

# developer-plenger/skills
**developer-plenger/skills** sebagai **satu Skill Pack end-to-end**, bukan kumpulan skill yang berdiri sendiri. Prinsip utamanya: setiap fase menghasilkan artifact yang menjadi input fase berikutnya, sementara `AGENTS.md` menjadi sumber konteks dan aturan workflow.

## 1. Konsep Pack

Dengan workflow:

```text
                    ┌─────────────┐
                    │    INIT     │
                    │ AGENTS.md   │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    PLAN     │
                    │ Idea → Spec │
                    └──────┬──────┘
                           │
                           ▼
                    ┌─────────────┐
                    │    SLICE    │
                    │ Spec → Tasks│
                    └──────┬──────┘
                           │
                           ▼
              ┌────────────┴────────────┐
              │                         │
              ▼                         ▼
        ┌───────────┐             ┌───────────┐
        │   EXEC    │             │   CHECK   │
        │ Task → Code│            │ Tests     │
        └─────┬─────┘             └─────▲─────┘
              │                         │
              ▼                         │
        ┌───────────┐                   │
        │  REVIEW   │───────────────────┘
        │ Code → MR │
        └───────────┘
```

Namun secara praktik, saya menyarankan `CHECK` **tidak otomatis dilakukan setelah setiap `EXEC` task**, melainkan setelah satu slice/phase selesai, kecuali task tersebut memang membutuhkan test langsung.

---

# 2. Struktur Folder Utama

Saya akan membuat struktur seperti ini:

```text
developer-plenger/skills/
│
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
│
├── skills/
│   │
│   ├── init/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       └── agents-template.md
│   │
│   ├── plan/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── discovery.md
│   │       ├── evaluation.md
│   │       ├── specification.md
│   │       └── context.md
│   │
│   ├── slice/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── vertical-slice.md
│   │       ├── tracer-bullet.md
│   │       ├── dependency.md
│   │       └── task-state.md
│   │
│   ├── exec/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── implementation.md
│   │       ├── completion.md
│   │       └── task-state.md
│   │
│   ├── review/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── review-checklist.md
│   │       ├── findings.md
│   │       └── task-state.md
│   │
│   └── check/
│       ├── SKILL.md
│       ├── agents/
│       │   └── openai.yaml
│       └── references/
│           ├── testing.md
│           ├── result.md
│           └── task-state.md
│
├── templates/
│   ├── AGENTS.md
│   ├── SPEC.md
│   ├── CONTEXT.md
│   ├── PHASE.md
│   ├── REVIEW.md
│   └── CHECK.md
│
├── docs/
│   ├── workflow.md
│   ├── architecture.md
│   └── state-machine.md
│
└── README.md
```

---

# 3. Kenapa Struktur Seperti Ini?

Saya akan memisahkan menjadi **3 layer**:

```text
skills/
    → Behaviour AI

templates/
    → Bentuk output

docs/
    → Dokumentasi pack
```

Jangan memasukkan template terlalu banyak ke dalam `SKILL.md`.

Misalnya `plan/SKILL.md` tidak perlu berisi seluruh format `SPEC.md`. Cukup:

```text
1. memahami ide
2. mengevaluasi
3. mengidentifikasi ambiguity
4. bertanya
5. membuat SPEC.md
6. membuat/update CONTEXT.md
```

Detail formatnya ditaruh di:

```text
skills/plan/references/specification.md
```

Ini mengikuti prinsip **progressive disclosure** yang juga cocok dengan pola repository Matt Pocock yang sebelumnya kita bahas.

---

# 4. Skill `init`

`init` adalah entry point.

Tujuannya bukan membuat project.

Tujuannya adalah **menyiapkan AI operating context untuk project**.

Invocation:

```text
/init
```

Kemudian AI:

```text
Detect project
      ↓
Inspect existing files
      ↓
Understand project
      ↓
Create AGENTS.md
      ↓
Register E2E workflow
```

Output:

```text
AGENTS.md
```

Isi konseptual:

```text
# Project Context

## Project
...

## Purpose
...

## Target Users
...

## Features
...

## Architecture
...

## Technology
...

## Workflow

1. PLAN
2. SLICE
3. EXEC
4. REVIEW
5. CHECK

## Skill Rules

### PLAN
...

### SLICE
...

### EXEC
...

### REVIEW
...

### CHECK
...

## Project Rules
...
```

Yang penting:

**`AGENTS.md` bukan hanya dokumentasi.**

Ia menjadi **shared context** yang dibaca oleh skill lain.

---

# 5. Skill `plan`

Ini adalah skill paling kompleks setelah `exec`.

Invocation:

```text
/plan
```

Input:

```text
Saya ingin membuat aplikasi untuk...
```

Tidak perlu user membuat PRD sendiri.

Pipeline:

```text
User Idea
   │
   ▼
Understand
   │
   ▼
Critique
   │
   ├── Target User
   ├── Features
   ├── Development
   ├── Security
   └── Scalability
   │
   ▼
Identify Ambiguity
   │
   ▼
Ask Questions
   │
   ▼
Resolve Decisions
   │
   ▼
Generate Specification
   │
   ├── SPEC.md
   └── CONTEXT.md
```

### Output

Saya sarankan:

```text
docs/
└── plan/
    ├── SPEC.md
    └── CONTEXT.md
```

`SPEC.md` = **apa yang akan dibuat**

`CONTEXT.md` = **apa yang harus terus diingat AI**

Ini dua hal yang berbeda.

---

# 6. Struktur `SPEC.md`

Contoh struktur:

```markdown
# Project Specification

## 1. Overview

## 2. Problem Statement

## 3. Goals

## 4. Non-Goals

## 5. Target Users

## 6. User Roles

## 7. User Stories

## 8. Functional Requirements

### Feature A

### Feature B

### Feature C

## 9. Business Logic

## 10. User Flow

## 11. Technical Requirements

## 12. Security Requirements

## 13. Scalability Considerations

## 14. Data Requirements

## 15. Integration Requirements

## 16. Constraints

## 17. Open Questions

## 18. Decisions

## 19. Acceptance Criteria
```

---

# 7. Struktur `CONTEXT.md`

Ini lebih ringkas.

```markdown
# Project Context

## Project

Nama project.

## Purpose

Tujuan project.

## Target Users

Siapa pengguna project.

## Core Features

- Feature A
- Feature B
- Feature C

## User Flow

...

## Important Business Rules

...

## Architecture

...

## Technology

...

## Current Development Status

...

## Important Decisions

...

## Known Constraints

...

## Current Phase

PLAN
```

Tujuannya agar agent tidak perlu membaca seluruh `SPEC.md` setiap kali.

---

# 8. Skill `slice`

Setelah:

```text
SPEC.md
```

sudah stabil:

```text
/slice
```

Pipeline:

```text
SPEC
 │
 ▼
Identify User Journeys
 │
 ▼
Identify Vertical Slices
 │
 ▼
Prioritize Tracer Bullets
 │
 ▼
Resolve Dependencies
 │
 ▼
Generate Phases
 │
 ▼
Generate Tasks
```

Output:

```text
docs/
└── phases/
    ├── phase-01-foundation.md
    ├── phase-02-authentication.md
    ├── phase-03-core-feature.md
    ├── phase-04-dashboard.md
    └── phase-05-hardening.md
```

---

# 9. Format Phase

Contohnya:

```markdown
# Phase 01 — Foundation

## Objective

...

## Vertical Slice

User dapat ...

## Tracer Bullet

...

## Dependencies

### BLOCKED BY

- None

### BLOCKS

- Phase 02

---

## Tasks

### TASK-001 — Initialize Application

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

...

#### Acceptance Criteria

- ...

#### Dependencies

- None

---

### TASK-002 — Setup Database

- [ ] Implemented
- [ ] Reviewed
- [ ] Tested

#### Description

...

#### Acceptance Criteria

- ...

#### Dependencies

- TASK-001
```

---

# 10. State Task

Saya justru menyarankan **jangan menggunakan satu variable seperti `status: done`**.

Gunakan tiga state independen:

```yaml
implemented: false
reviewed: false
tested: false
```

Karena kondisi seperti ini valid:

```yaml
implemented: true
reviewed: false
tested: false
```

Artinya:

> kode sudah dibuat tetapi belum direview dan dites.

Atau:

```yaml
implemented: true
reviewed: true
tested: false
```

Artinya:

> implementasi dan review selesai, testing belum.

Ini jauh lebih fleksibel.

---

# 11. Skill `exec`

Invocation:

```text
/exec TASK-001
```

atau:

```text
/exec phase-01
```

Pipeline:

```text
Read AGENTS.md
      ↓
Read CONTEXT.md
      ↓
Read SPEC.md
      ↓
Read Phase
      ↓
Identify Task
      ↓
Check Dependencies
      ↓
Inspect Existing Code
      ↓
Implement
      ↓
Validate
      ↓
Update Task State
```

Output utamanya:

```text
source code
```

Bukan markdown.

Tetapi setelah selesai:

```yaml
implemented: true
reviewed: false
tested: false
```

---

# 12. Skill `review`

Invocation:

```text
/review TASK-001
```

atau:

```text
/review phase-01
```

Pipeline:

```text
Task
 ↓
Specification
 ↓
Acceptance Criteria
 ↓
Implementation
 ↓
Review
 ├── Logic
 ├── Architecture
 ├── Security
 ├── Maintainability
 ├── Edge Cases
 └── Requirement Compliance
 ↓
Generate Review
 ↓
Update State
```

Output:

```text
docs/
└── reviews/
    └── TASK-001.md
```

Contoh:

```markdown
# Review — TASK-001

## Summary

...

## Findings

### FINDING-001

Severity: Medium

...

## Recommended Changes

...

## Verification

...

## Status

Reviewed: true
```

Kemudian task:

```yaml
implemented: true
reviewed: true
tested: false
```

---

# 13. Skill `check`

Invocation:

```text
/check TASK-001
```

atau:

```text
/check phase-01
```

Skill ini harus **mendeteksi testing ecosystem**, bukan mengasumsikan Jest/Vitest/Go test/etc.

Misalnya:

```text
package.json
    ↓
Vitest detected

atau

go.mod
    ↓
Go testing detected

atau

pytest configuration
    ↓
Pytest detected
```

Kemudian:

```text
Detect Test Framework
        ↓
Determine Existing Tests
        ↓
Run Tests
        ↓
Analyze Result
        ↓
Generate CHECK.md
        ↓
Update Task
```

Output:

```text
docs/
└── checks/
    └── TASK-001.md
```

---

# 14. State Machine

Saya sarankan pack ini memiliki aturan state yang eksplisit.

```text
                    ┌──────────────┐
                    │ NOT STARTED  │
                    └──────┬───────┘
                           │
                           ▼
                    ┌──────────────┐
                    │ IMPLEMENTED  │
                    └──────┬───────┘
                           │
                    ┌──────┴───────┐
                    │              │
                    ▼              ▼
               ┌─────────┐   ┌─────────┐
               │ REVIEWED│   │ TESTED  │
               └────┬────┘   └────┬────┘
                    │              │
                    └──────┬───────┘
                           ▼
                    ┌──────────────┐
                    │    DONE      │
                    └──────────────┘
```

Tetapi `DONE` **tidak perlu disimpan sebagai variable**.

Derived state:

```text
implemented = true
reviewed    = true
tested      = true
```

berarti:

```text
DONE
```

---

# 15. Dependency Antar Skill

Ini bagian penting.

Saya akan membuat dependency seperti:

```text
init
 │
 ▼
plan
 │
 ▼
slice
 │
 ▼
exec
 │
 ├──────────────┐
 ▼              ▼
review         check
 │              │
 └──────┬───────┘
        ▼
      DONE
```

Tetapi `review` dan `check` **tidak boleh dianggap sebagai dependency implementation**.

Karena:

```text
exec → review
exec → check
```

bukan:

```text
exec → review → check
```

Dengan begitu developer bisa:

```text
exec
 ↓
review
 ↓
fix
 ↓
review
 ↓
check
```

---

# 16. Saya Juga Menyarankan `fix`

Walaupun tidak ada di requirement awalmu, secara arsitektur pack ini akan jauh lebih lengkap jika ada:

```text
fix
```

Karena `review` menghasilkan finding.

Misalnya:

```text
REVIEW
  ↓
Finding
  ↓
FIX
  ↓
REVIEW AGAIN
```

Tanpa `fix`, user harus memberikan hasil review kembali ke `exec`.

Saya akan membuatnya sebagai **optional skill**, bukan core skill.

Strukturnya:

```text
skills/
├── init/
├── plan/
├── slice/
├── exec/
├── review/
├── check/
└── fix/
```

Flow:

```text
                 ┌─────────┐
                 │  EXEC   │
                 └────┬────┘
                      │
              ┌───────┴────────┐
              ▼                ▼
         ┌─────────┐      ┌─────────┐
         │ REVIEW  │      │  CHECK  │
         └────┬────┘      └────┬────┘
              │                │
          findings          failures
              │                │
              ▼                ▼
         ┌─────────────────────────┐
         │           FIX           │
         └────────────┬────────────┘
                      │
                      ▼
                   REVIEW
```

---

# 17. Final Folder Structure yang Saya Rekomendasikan

Jadi versi finalnya:

```text
developer-plenger/skills/
│
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
│
├── skills/
│   │
│   ├── init/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       └── agents-template.md
│   │
│   ├── plan/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── discovery.md
│   │       ├── evaluation.md
│   │       ├── specification.md
│   │       └── context.md
│   │
│   ├── slice/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── vertical-slice.md
│   │       ├── tracer-bullet.md
│   │       ├── dependency.md
│   │       └── task-state.md
│   │
│   ├── exec/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── implementation.md
│   │       ├── completion.md
│   │       └── task-state.md
│   │
│   ├── review/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── review-checklist.md
│   │       ├── findings.md
│   │       └── task-state.md
│   │
│   ├── check/
│   │   ├── SKILL.md
│   │   ├── agents/
│   │   │   └── openai.yaml
│   │   └── references/
│   │       ├── testing.md
│   │       ├── result.md
│   │       └── task-state.md
│   │
│   └── fix/
│       ├── SKILL.md
│       ├── agents/
│       │   └── openai.yaml
│       └── references/
│           ├── remediation.md
│           └── task-state.md
│
├── templates/
│   ├── AGENTS.md
│   ├── SPEC.md
│   ├── CONTEXT.md
│   ├── PHASE.md
│   ├── REVIEW.md
│   └── CHECK.md
│
├── docs/
│   ├── workflow.md
│   ├── architecture.md
│   └── state-machine.md
│
└── README.md
```

## 18. Hal yang paling penting dari desain ini

Saya akan menjadikan **`AGENTS.md` + `CONTEXT.md` + task state** sebagai tiga mekanisme utama context management:

```text
AGENTS.md
    │
    │ "Bagaimana AI harus bekerja?"
    ▼
CONTEXT.md
    │
    │ "Project ini sebenarnya apa?"
    ▼
SPEC.md
    │
    │ "Apa yang harus dibangun?"
    ▼
PHASE/*.md
    │
    │ "Apa yang harus dikerjakan?"
    ▼
TASK STATE
    │
    │ "Apa yang sudah dilakukan?"
    ▼
CODE
```


