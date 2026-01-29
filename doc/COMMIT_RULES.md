# Commit Rules

Commit requirements and message conventions for this repository.

## Core principles
- Each commit contains one logical change (one purpose, one topic).
- Keep commits small, reviewable, and reversible.
- Before committing, ensure `lake env lean <file>` or `lake build` passes.
- Do not commit generated or temporary files (e.g. `.lake/`, `.vscode/.history/`).
- Never commit secrets (tokens, passwords, personal data).

## Commit message format
Use a concise "type + summary" format:

```
<type>: <summary>

<body>
```

### Allowed types
- `feat`: new functionality, definition, or axiom
- `fix`: bug fix or incorrect proof
- `refactor`: structural change without behavior change
- `docs`: documentation or comment updates
- `chore`: build/tooling/config updates (no semantic change)
- `test`: add or adjust examples, `#check`, test-like proofs

### Summary rules
- Start with a verb and explain the "why" rather than re-listing the change.
- 40–60 characters preferred; avoid trailing periods.
- Examples:
  - `feat: add stabilizer subgroup definition`
  - `fix: correct phi_mul proof to use ext`
  - `docs: clarify GroupAction conventions`

### Body rules
- Explain motivation, context, or non-obvious design choices.
- Include verification when useful:
  - `Check: lake env lean lean/GroupAction/Examples.lean`
- Note known limitations or follow-ups explicitly.

## Scope and change constraints
- Avoid large cross-file changes; split when necessary.
- When fixing bugs, do not refactor at the same time.
- Do not add new dependencies without explicit agreement.
- Follow existing Lean style: naming, indentation, and comments.

## Example commit
```
feat: add permutation representation lemma

Explain why this lemma is needed for later stabilizer results.
Check: lake env lean lean/GroupAction/Permutation.lean
```

## Prohibited
- Do not commit `sorry`.
- Do not commit `.lake/` build artifacts or editor history files.
- Do not mix unrelated changes in a single commit.
