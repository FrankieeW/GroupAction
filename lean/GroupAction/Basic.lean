/-
Title: Basic.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/GroupAction
-/
import GroupAction.Defs

/-! ## Basic lemmas and theorems about group actions -/

variable {G : Type*} [Group G] {X : Type*} [GroupAction G X]


-- theorem b
theorem faithful_def {G : Type*} [Group G] {X : Type*} [GroupAction G X] :
    GroupAction.faithful (G := G) (X := X) ↔
      ∀ g₁ g₂ : G, (∀ x : X, GroupAction.act g₁ x = GroupAction.act g₂ x) → g₁ = g₂ :=
  Iff.rfl

-- theorem by definition
theorem transitive_def {G : Type*} [Group G] {X : Type*} [GroupAction G X] :
    GroupAction.transitive (G := G) (X := X) ↔
      ∀ x₁ x₂ : X, ∃ g : G, GroupAction.act g x₁ = x₂ :=
  Iff.rfl

#lint
