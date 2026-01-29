# Project 1: Group Actions

## 🚧 BRANCH: feat/lean-latex-automation

**Status**: Development branch for Lean-LaTeX automation system
**Purpose**: Implement automated maintenance of Lean code references in LaTeX documents
**Completion**: 27/27 success criteria met, all tests passing, LaTeX compiles successfully

### Branch Plan & Progress

✅ **COMPLETED (27/27 success criteria)**
- [x] Lean parser: Extract definitions, theorems, instances from .lean files
- [x] LaTeX parser: Parse existing \leancodefile calls and TODO markers
- [x] Intelligent matcher: Match LaTeX references to Lean definitions
- [x] Line range calculator: Include surrounding comments in ranges
- [x] LaTeX updater: Generate corrected \leancodefile calls
- [x] TODO marker support: %TODO:lean-name → automatic \leancodefile insertion
- [x] Integration & testing: Full automation pipeline working
- [x] LaTeX compilation fixes: Resolved tabular environment errors

### Key Features Implemented
- **Dual Mode Operation**: Maintain existing references + insert from TODO markers
- **Smart Matching**: Exact name matching + suffix matching (e.g., "faithful" → "GroupAction.faithful")
- **Comment Inclusion**: Automatically include comments above/below definitions
- **GitHub Integration**: Generate proper GitHub URLs for code links
- **Error Handling**: Comprehensive validation and user-friendly error messages

### Usage
```bash
# Analyze Lean files and LaTeX references
python automation/lean_latex_linker.py --analyze

# View matching results
python automation/lean_latex_linker.py --match

# Apply automated updates
python automation/lean_latex_linker.py --update

# Run tests
python automation/tests/test_automation.py
```

### Files Added/Modified
- `automation/`: Complete automation system (parser, matcher, updater, linker)
- `tex/report.tex`: All \leancodefile calls converted to TODO markers and auto-updated
- `README.md`: This branch documentation

**Next Steps**: Merge to main after review, or continue development on this branch.

---

Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved. Repository: https://github.com/FrankieeW/formalising-mathematics-notes

This folder contains a Lean 4 formalisation of basic group action theory, focusing on the permutation representation induced by an action and the stabilizer subgroup of a point.

## Table of contents

- [Project 1: Group Actions](#project-1-group-actions)
  - [Table of contents](#table-of-contents)
  - [Overview](#overview)
  - [Files](#files)
  - [Mathematical focus](#mathematical-focus)
  - [Prerequisites](#prerequisites)
  - [How to check the project](#how-to-check-the-project)
  - [Conventions](#conventions)
  - [Commit rules](#commit-rules)
  - [Version history](#version-history)
  - [Progress](#progress)
    - [v1.0 completed](#v10-completed)
    - [v1.0 next improvements（planned by AI）](#v10-next-improvementsplanned-by-ai)
  - [References](#references)

## Overview

- Defines a `GroupAction` class (action of a monoid on a type).
- Builds the permutation representation `phi : G → Equiv.Perm X`.
- Proves core lemmas about `phi` and the stabilizer subgroup.
- Previous monolithic version: https://github.com/FrankieeW/formalising-mathematics-notes/blob/pre-project1-split/Project1/Main.lean

## Files

- `lean/GroupAction/Defs.lean` defines `GroupAction` and core axioms.
- `lean/GroupAction/Basic.lean` adds basic lemmas for the action.

## Mathematical focus

- Group actions (monoid actions used for the definition).
- Permutation representations of group actions.
- Stabilizer sets and subgroups.

## Prerequisites

- Lean 4 with mathlib (see the repo root for setup).
- Run `lake exe cache get` once after cloning to download the mathlib cache.

## How to check the project

From the repository root:

```bash
lake env lean lean/GroupAction.lean
```

To build the full project instead:

```bash
lake build
```

## Conventions

- Imports live at the top of the file.
- Proofs use readable tactic scripts (`intro`, `apply`, `simp`) with two-space indentation.
- Names like `hP` denote hypotheses, and `P Q R` are propositions.

## Commit rules

See `doc/COMMIT_RULES.md` for commit message format and constraints.

## Version history

- v1.0 (first release)

## Progress

### v1.0 completed

- Defined a minimal `GroupAction` class and core action API.
- Constructed the permutation representation `phi : G → Equiv.Perm X`.
- Formalised stabilizer sets and their subgroup structure.
- Wrote a reader-facing report with Lean excerpts.
- Added a checklist for self/AI scoring in `tex/checklist.md`.

### v1.0 next improvements（planned by AI）

- Add a brief glossary of Lean tactics used (e.g., `simp`, `ring_nf`).
- Include a short example showing how to run `lake env lean` on `lean/GroupAction.lean`.
- Add a one-paragraph roadmap outlining possible extensions (orbit-stabilizer, action on cosets).
- Clarify where the custom `GroupAction` diverges from `MulAction` and why.
- Provide a small commutative diagram showing `G → Sym(X)` and evaluation at `x`.
- Add a short appendix listing the main lemmas and where they appear in `lean/GroupAction/Basic.lean`.
- Add one example instantiation (e.g., `G = S₃` acting on `{1,2,3}`).

## References

- John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
  Addison–Wesley, 2003, Section 16 (Group Actions).
