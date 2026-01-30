/-
Title: GroupAction.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/formalising-mathematics-notes
-/
import GroupAction.Basic
import GroupAction.Defs
import GroupAction.Examples
import GroupAction.Permutation
import GroupAction.Stabilizer

/-
# Project 1 : Group Actions

## Overview
This file introduces a custom `GroupAction` and builds the permutation
representation `phi : G → Equiv.Perm X`, then proves basic properties
such as multiplicativity and the stabilizer subgroup.

## References
John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
Addison–Wesley, 2003, Section 16 (Group Actions).
-/

#lint
