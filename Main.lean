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
-- Group action
structure GroupAction (G : Type*) [Group G] (X : Type*) where
  act : G → X → X
  ga1 : ∀ (g1 g2 : G) (x : X), act (g1 * g2) x = act g1 (act g2 x)
  ga2 : ∀ (x : X), act (1 : G) x = x

-- Such X is called a G-set
def IsGSet (G : Type*) [Group G] (X : Type*) :=
  GroupAction G X

/-! ## Example -/
-- X = {1,2,...,n}, G = S_n (test my def)
-- S_n is represented by Equiv.Perm (Fin n) in mathlib
example (n : Nat) : IsGSet (Equiv.Perm (Fin n)) (Fin n) :=
  { act := λ g x => g x
    ga1 := by
      intros g1 g2 x
      rw [Equiv.Perm.mul_apply]
    ga2 := by
      intro x
      rw [Equiv.Perm.one_apply]
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
  (actX : IsGSet G X) :
  ∃ (φ : G → Equiv.Perm X),
    (∀ g : G, ∀ x : X, φ g x = actX.act g x) ∧
    (∀ g1 g2 : G, φ (g1 * g2) = φ g1 * φ g2) ∧
    (φ 1 = 1) := by
  sorry
