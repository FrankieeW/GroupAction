/-
Title: Stabilizer.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/
-/
import GroupAction.Defs
import Mathlib.Algebra.Group.Subgroup.Basic

/-!
# Stabilizer (isotropy subgroup)
## Theorem: Let X be a G-set. Then Gₓ is a subgroup of G for each x ∈ X.

Let X be a G-set. Let x ∈ X and g ∈ G. It will be important to know
when g x = x. We let
Gₓ = { g ∈ G | g x = x }, X_g = { x ∈ X | g x = x }.
-/

variable {G : Type*} [Group G] {X : Type*} [GroupAction G X]

/-- The stabilizer set
    `G_x = { g ∈ G | g • x = x }`. -/
def stabilizerSet (x : X) : Set G :=
  { g : G | GroupAction.act g x = x }

/-- The stabilizer `G_x` as a subgroup of `G`. -/
def stabilizer (x : X) : Subgroup G := by
  exact
    { carrier := stabilizerSet (G := G) (X := X) x
      one_mem' := by
        -- The identity fixes every x.
        simp [stabilizerSet, GroupAction.ga_one x]
      mul_mem' := by
        intro g₁ g₂ hg₁ hg₂
        calc
          -- Closure under multiplication via the action axiom.
          GroupAction.act (g₁ * g₂) x = GroupAction.act g₁ (GroupAction.act g₂ x) := by
            simpa using (GroupAction.ga_mul g₁ g₂ x)
          _ = GroupAction.act g₁ x := by
            rw [hg₂]
          _ = x := hg₁
      inv_mem' := by
        intro g hg
        calc
          -- If g fixes x, then g⁻¹ fixes x as well.
          GroupAction.act g⁻¹ x = GroupAction.act g⁻¹ (GroupAction.act g x) := by
            rw [hg]
          _ = GroupAction.act (g⁻¹ * g) x := by
            simpa using (GroupAction.ga_mul g⁻¹ g x).symm
          _ = GroupAction.act (1 : G) x := by simp
          _ = x := GroupAction.ga_one x }

/-- The stabilizer set is the carrier of a subgroup of `G`. -/
theorem stabilizer_set_is_subgroup (x : X) :
    ∃ H : Subgroup G, (H : Set G) = stabilizerSet (G := G) (X := X) x := by
  refine ⟨stabilizer (G := G) (X := X) x, ?_⟩
  rfl

#lint
