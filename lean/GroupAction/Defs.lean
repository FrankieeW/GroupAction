/-
Title: Defs.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/
-/
import Mathlib.Algebra.Group.Basic
import Mathlib.GroupTheory.Perm.Basic

/-! ## Definitions: group actions -/
/-- Defines a group action of a monoid `G` on a type `X`.
The action is given by `act : G → X → X`,
satisfying the axioms `ga_mul` and `ga_one`. -/
class GroupAction (G : Type*) [Monoid G] (X : Type*) where
  /-- The action function that applies a group element to an element of `X`. -/
  act : G → X → X
  /-- The multiplication axiom: `(g₁ * g₂) • x = g₁ • (g₂ • x)`. -/
  ga_mul : ∀ g₁ g₂ x, act (g₁ * g₂) x = act g₁ (act g₂ x)
  /-- The identity axiom: `1 • x = x`. -/
  ga_one : ∀ x, act 1 x = x


/-! ## Definitions: act faithfully -/
/-- A group action is faithful if different group elements
act differently on at least one element of `X`. -/
def GroupAction.faithful {G : Type*} [Group G] {X : Type*} [GroupAction G X] : Prop :=
  ∀ g₁ g₂ : G, (∀ x : X, GroupAction.act g₁ x = GroupAction.act g₂ x) → g₁ = g₂



/-! ## Definitions: transitive -/
/-- A group action is transitive if for any `x₁, x₂ ∈ X`,
there exists a group element `g ∈ G` such that `g • x₁ = x₂`. -/
def GroupAction.transitive {G : Type*} [Group G] {X : Type*} [GroupAction G X] : Prop :=
  ∀ x₁ x₂ : X, ∃ g : G, GroupAction.act g x₁ = x₂

#lint
