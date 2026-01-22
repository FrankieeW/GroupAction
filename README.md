# Project 1: Group Actions

This folder contains a Lean 4 formalisation of basic group action theory, focusing on the permutation representation induced by an action and the stabilizer subgroup of a point.

## Overview

- Defines a `GroupAction` class (action of a monoid on a type).
- Builds the permutation representation `phi : G → Equiv.Perm X`.
- Proves core lemmas about `phi` and the stabilizer subgroup.

## Contents

- `Main.lean` defines `GroupAction`, `sigma`, `phi`, and stabilizer constructions.
- `Test.lean` is empty and can be used for scratch work.

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
lake env lean Project1/Main.lean
```

To build the full project instead:

```bash
lake build
```

## Conventions

- Imports live at the top of the file.
- Proofs use readable tactic scripts (`intro`, `apply`, `simp`) with two-space indentation.
- Names like `hP` denote hypotheses, and `P Q R` are propositions.

## References

- John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
  Addison–Wesley, 2003, Section 16 (Group Actions).
