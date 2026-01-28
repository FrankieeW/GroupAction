/-
Title: Main.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/formalising-mathematics-notes
-/
import Mathlib.Tactic
import Mathlib.Data.SetLike.Basic
import Mathlib.Data.Fintype.Card
import Mathlib.Algebra.Group.Basic
import Mathlib.Algebra.Group.Subgroup.Basic
import Mathlib.GroupTheory.Perm.Basic
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



/-! ## Definitions: group actions -/
/-- Defines a group action of a monoid `G` on a type `X`.
The action is given by `act : G → X → X`,
satisfying the axioms `ga_mul` and `ga_one`. -/
class GroupAction (G : Type*) [Monoid G] (X : Type*) where
  act : G → X → X
  ga_mul : ∀ g₁ g₂ x, act (g₁ * g₂) x = act g₁ (act g₂ x)
  ga_one : ∀ x, act 1 x = x

variable {G : Type*} [Group G] {X : Type*} [GroupAction G X]



-- /-!
-- ## Example

/-- The symmetric group `Equiv.Perm X` acts on `X` by evaluation. -/
instance permGroupAction (X : Type*) : GroupAction (Equiv.Perm X) X :=
  { act := fun g x => g x
    ga_mul := by
      intro g1 g2 x
      rfl
    ga_one := by
      intro x
      rfl }


instance groupAsGSet (G : Type*) [Group G] : GroupAction G G :=
  { act := fun g1 g2 => g1 * g2
    ga_mul := by
      intro g1 g2 g3
      rw [mul_assoc]
    ga_one := by
      intro g
      rw [one_mul] }


instance subgroupAsGSet {G : Type*} [Group G] (H : Subgroup G) : GroupAction H G :=
  { act := fun h g => (h : G) * g
    ga_mul := by
      intros
      -- simp
      -- rw [mul_assoc]
      simp [mul_assoc]
    ga_one := by
      intros
      simp
  }

instance subgroupAsGSetConjugation {G : Type*} [Group G] (H : Subgroup G) : GroupAction H H :=
  { act := fun h g => h * g * h⁻¹
    ga_mul := by
      intro g₁ g₂ g₃
      -- simp [mul_assoc]
      simp
      -- goal state: g₁ * g₂ * g₃ * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃ * g₂⁻¹) * g₁⁻¹
      rw [ ← mul_assoc g₁]
      -- goal state: g₁ * g₂ * g₃ * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃) * g₂⁻¹ * g₁⁻¹
      rw [mul_assoc g₁ g₂]
      -- goal state:  g₁ * (g₂ * g₃) * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃) * g₂⁻¹ * g₁⁻¹
      rw [← mul_assoc]
    ga_one := by
      intros
      simp
  }
instance vectorSpaceAsCStarSet (n : ℕ) :
    GroupAction (ℂˣ) (Fin n → ℂ) :=
  { act := fun r v => fun i => (r : ℂ) * v i
    ga_mul := by
      intros r1 r2 v
      ext i
      simp [mul_assoc]
    ga_one := by
      intro v
      ext i
      simp
  }
instance vectorSpaceAsRStarSet (n : ℕ) :
    GroupAction (ℝˣ) (Fin n → ℝ) :=
  -- using vectorSpaceAsCStarSet
  { act := fun r v => fun i => (r : ℝ) * v i
    ga_mul := by
      intros r1 r2 v
      ext i
      simp [mul_assoc]
    ga_one := by
      intro v
      ext i
      simp
  }


/-!

## Theorem: permutation representation

Let `X` be a `G`-set.

1. For each `g ∈ G`, define `σ_g : X → X` by `σ_g(x) = g • x`.
   This map is a permutation of `X` (a bijection).
2. Define `φ : G → Sym X` by `φ(g) = σ_g`.
   This map is a group homomorphism.

Moreover, for all `g ∈ G` and `x ∈ X`, we have `φ(g)(x) = g • x`.
-/

-- The following statement is a commented-out sketch of the main theorem.
-- theorem group_action_to_perm_representation
--   {G : Type*} [Group G]
--   {X : Type*} [GroupAction G X]
--   (actX : GroupAction G X) :
--   ∃ (φ : G → Equiv.Perm X), -- `Equiv.Perm X` is Lean's `Sym X`.
--     (∀ g : G, ∀ x : X, φ g x = actX.act g x) ∧
--     (∀ g1 g2 : G, φ (g1 * g2) = φ g1 * φ g2) ∧
--     (φ 1 = 1) := by
--   sorry

/-- Defines the action map `σ_g : X → X` by `x ↦ g • x`. -/
def sigma (g : G) : X → X :=
  fun x => GroupAction.act g x
#check sigma
/-- Defines the permutation of `X` induced by `g`.
    The inverse is given by the action of `g⁻¹`. -/
def sigmaPerm (g : G) : Equiv.Perm X :=
  { toFun := sigma g
    invFun := sigma g⁻¹
    left_inv := by

      intro x --  ⊢ sigma g⁻¹ (sigma g x) = x
      calc
        -- Step 1: combine `g⁻¹` and `g` using the action axiom.
        GroupAction.act g⁻¹ (GroupAction.act g x) =
            GroupAction.act (g⁻¹ * g) x := by
          simpa using (GroupAction.ga_mul g⁻¹ g x).symm
        -- Step 2: simplify `g⁻¹ * g` to `1`.
        _ = GroupAction.act (1 : G) x := by
          -- Alternative: use `congrArg` with `inv_mul_cancel g`.
          -- congrArg (fun t => GroupAction.act t x) (inv_mul_cancel g)
          simp
        -- Step 3: the identity acts as the identity on `X`.
        _ = x := GroupAction.ga_one x
    right_inv := by
      intro x
      calc
        -- Step 1: combine `g` and `g⁻¹` using the action axiom.
        GroupAction.act g (GroupAction.act g⁻¹ x) =
            GroupAction.act (g * g⁻¹) x := by
          simpa using (GroupAction.ga_mul g g⁻¹ x).symm
        -- Step 2: simplify `g * g⁻¹` to `1`.
        _ = GroupAction.act (1 : G) x := by
          -- Alternative: use `congrArg` with `mul_inv_cancel g`.
          -- congrArg (fun t => GroupAction.act t x) (mul_inv_cancel g)
          simp
        -- Step 3: the identity acts as the identity on `X`.
        _ = x := GroupAction.ga_one x }
#check sigmaPerm
/-- Defines the permutation representation `phi : G → Equiv.Perm X`.
    This sends `g` to the permutation `σ_g`. -/
def phi (g : G) : Equiv.Perm X :=
  sigmaPerm g

/-- `phi` agrees with the action on each element of `X`. -/
lemma phi_apply (g : G) (x : X) : phi g x = GroupAction.act g x := rfl


-- /-- A commented-out attempt at proving multiplicativity of `phi`. -/
-- lemma phi_mul : ∀ (g₁ g₂ : G), phi (g₁ * g₂) = phi g₁ * phi g₂ := by
--   sorry
/-- Shows that `phi` respects multiplication:
    `phi (g₁ * g₂) = phi g₁ * phi g₂`. -/
lemma phi_mul (g₁ g₂ : G) :
  phi (X := X) (g₁ * g₂) = phi (X := X) g₁ * phi (X := X) g₂ := by
  -- Extensionality reduces equality of permutations to pointwise equality.
  apply Equiv.ext
  intro (x : X)
  calc
    -- Step 1: expand `phi` and the action definition.
    phi (g₁ * g₂) x = GroupAction.act (g₁ * g₂) x := rfl
    -- Step 2: use the action axiom to separate `g₁` and `g₂`.
    _ = GroupAction.act g₁ (GroupAction.act g₂ x) := GroupAction.ga_mul g₁ g₂ x


/-- `phi 1` is the identity permutation. -/
lemma phi_one : phi (1 : G) = (1 : Equiv.Perm X) := by
  apply Equiv.ext
  intro (x : X)
  calc
    phi (1 : G) x = GroupAction.act (1 : G) x := rfl
    _ = x := GroupAction.ga_one x
    _ = (1 : Equiv.Perm X) x := by
      simp [Equiv.Perm.one_apply]

/-- The action yields a permutation representation. -/
theorem group_action_to_perm_representation :
  ∃ (φ : G → Equiv.Perm X),
    (∀ g x, φ g x = GroupAction.act g x) ∧
    (∀ g₁ g₂, φ (g₁ * g₂) = φ g₁ * φ g₂) ∧
    (φ 1 = 1) := by
  -- Compact term:
  exact ⟨phi, ⟨phi_apply, ⟨phi_mul, phi_one⟩⟩⟩
  --
   -- Expanded proof (step-by-step):
  -- refine ⟨phi, ?_⟩ -- provide φ = phi
    -- refine ⟨phi_apply, ?_⟩ -- provide φ g x = g • x
    -- refine ⟨phi_mul, ?_⟩ -- provide φ (g₁ * g₂) = φ g₁ * φ g₂
    -- exact phi_one -- provide φ 1 = 1

-- Moreover, for all g ∈ G and x ∈ X,
-- we have φ(g)(x) = g • x.
/-- For the permutation representation `φ`, we have `φ g x = g • x` for all `g` and `x`. -/
theorem group_action_to_perm_representation_apply
  -- For all g ∈ G and x ∈ X.
  {g : G} {x : X}
  -- Given φ.
  (φ : G → Equiv.Perm X)
  -- We have φ(g)(x) = g • x.
  (hφ : ∀ g x, φ g x = GroupAction.act g x) :
  φ g x = GroupAction.act g x :=
  -- By definition of hφ.
  hφ g x




/-!
# Stabilizer (isotropy subgroup)
## Theorem: Let X be a G-set. Then Gₓ is a subgroup of G for each x ∈ X.

Let X be a G-set. Let x ∈ X and g ∈ G. It will be important to know
when g x = x. We let
Gₓ = { g ∈ G | g x = x }, X_g = { x ∈ X | g x = x }.
-/
/-- The stabilizer set
    `G_x = { g ∈ G | g • x = x }`. -/
def stabilizerSet (x : X) : Set G :=
  { g : G | GroupAction.act g x = x }

/-- The stabilizer `G_x` as a subgroup of `G`. -/
def stabilizer (x : X) : Subgroup G := by
  exact
    { carrier := stabilizerSet (G := G) (X := X) x
      -- A submonoid(subgroup) contains 1.
      one_mem' := by
        -- The identity fixes every x.
        simp [stabilizerSet, GroupAction.ga_one x]
      -- The product of two elements of a subsemigroup belongs to the subsemigroup.
      mul_mem' := by
        intro g₁ g₂ hg₁ hg₂
        calc
          -- Closure under multiplication via the action axiom.
          GroupAction.act (g₁ * g₂) x = GroupAction.act g₁ (GroupAction.act g₂ x) := by
            simpa using (GroupAction.ga_mul g₁ g₂ x)
          _ = GroupAction.act g₁ x := by
            rw [hg₂]
          _ = x := hg₁
      -- G is closed under inverses.
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
  refine ⟨stabilizer (G := G) (X := X) x, rfl⟩


-- /-- The stabilizer set is the carrier of a subgroup of `G`. -/
-- theorem stabilizer_set_is_subgroup' (x : X) :
--     ∃ H : Subgroup G, (H : Set G) = stabilizerSet (G := G) (X := X) x := by
--   use
--     { carrier := stabilizerSet (G := G) (X := X) x
--       one_mem' := by
--         simp [stabilizerSet, GroupAction.ga_one x]
--       mul_mem' := by
--         intro g₁ g₂ hg₁ hg₂
--         calc
--           GroupAction.act (g₁ * g₂) x = GroupAction.act g₁ (GroupAction.act g₂ x) := by
--             simpa using (GroupAction.ga_mul g₁ g₂ x)
--           _ = GroupAction.act g₁ x := by
--             rw [hg₂]
--           _ = x := hg₁
--       inv_mem' := by
--         intro g hg
--         calc
--           GroupAction.act g⁻¹ x = GroupAction.act g⁻¹ (GroupAction.act g x) := by
--             rw [hg]
--           _ = GroupAction.act (g⁻¹ * g) x := by
--             simpa using (GroupAction.ga_mul g⁻¹ g x).symm
--           _ = GroupAction.act (1 : G) x := by simp
--           _ = x := GroupAction.ga_one x
--     }
--   rfl
-- /-- The stabilizer `G_x` as a subgroup of `G` (defined via choice). -/
-- noncomputable def stabilizer_via_choice (x : X) : Subgroup G :=
--   Classical.choose (stabilizer_set_is_subgroup' (G := G) (X := X) x)
-- theorem stabilizer_carrier_via_choice (x : X) :
--     (stabilizer_via_choice (G := G) (X := X) x : Set G) = stabilizerSet (G := G) (X := X) x :=
--   Classical.choose_spec (stabilizer_set_is_subgroup' (G := G) (X := X) x)
