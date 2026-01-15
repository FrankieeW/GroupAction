/-
Title: Main.lean
Author: Frankie Wang
Date: June 2026
Copyright (c) 2026 Frankie Wang. All rights reserved.
Contact: contact@frankie.wang
License: MIT
Github: https://github.com/FrankieeW/M
-/
import Mathlib.Tactic
import Mathlib.Data.SetLike.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Algebra.Group.Basic
import Mathlib.GroupTheory.Perm.Basic
import Mathlib.Algebra.Group.Action.Defs
-- import Mathlib.GroupTheory.Subgroup.Basic
/-!
# Project 1 : Group Actions

## Overview
We define group actions and show they yield permutation representations.

## References
John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
Addison–Wesley, 2003, Section 16 (Group Actions).
-/



/-! ## Definitions -/
-- Explicit definition of a group action on a fixed type X
structure GroupActionStruct (G : Type*) [Group G] (X : Type*) where
  act : G → X → X
  mul_act :
    ∀ (g₁ g₂ : G) (x : X),
      act (g₁ * g₂) x = act g₁ (act g₂ x)
  one_act :
    ∀ (x : X),
      act (1 : G) x = x

-- A G-set structure on X, such X is called a G-set
def GSetStructure (G : Type*) [Group G] (X : Type*) :=
  GroupActionStruct G X

/-
Remark.
This definition is equivalent to the standard typeclass
`MulAction G X` in mathlib, but is written explicitly here
to mirror the textbook definition and avoid typeclass machinery.
-/
#check MulAction
/-! ## Example -/
-- X = {1,2,...,n}, G = S_n (test my def)
-- S_n is represented by Equiv.Perm (Fin n) in mathlib
example (n : Nat) : GSetStructure (Equiv.Perm (Fin n)) (Fin n) :=
  { act := λ σ x => σ x,
    mul_act := by
      intros σ₁ σ₂ x
      simp only [Equiv.Perm.mul_apply],
    one_act := by
      intro x
      simp only [Equiv.Perm.one_apply]
      }


/-!
## Theorem: permutation representation

Let X be a G-set.

1. For each g ∈ G, define σ_g : X → X by σ_g(x) = g • x.
   Then σ_g is a permutation of X, i.e. a bijection X → X.

2. Define a map φ : G → Sym X by φ(g) = σ_g.
   Then φ is a group homomorphism.

Moreover, for all g ∈ G and x ∈ X, we have φ(g)(x) = g • x.
-/

theorem groupActionToPermRepresentation
  {G : Type*} [Group G]
  {X : Type*} [SetLike X X]
  (actStruct : GSetStructure G X) :
