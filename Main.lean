/-
Title: Main.lean
Author: Frankie Wang
Date: June 2026
Copyright (c) 2026 Frankie Wang. All rights reserved.
Contact: contact@frankie.wang
License: MIT
Github: https://github.com/FrankieeW/
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
We define group actions and show they yield permutation representations.

## References
John B. Fraleigh, Victor J. Katz, *A First Course in Abstract Algebra*,
Addison–Wesley, 2003, Section 16 (Group Actions).
-/



/-! ## Definitions -/
-- Group action (G on X)
-- (NOTE: G is a Monoid here, not necessarily a Group,
--  because inverses are not needed for the definition)
class GroupAction (G : Type*) [Monoid G] (X : Type*) where
  act : G → X → X
  ga_mul : ∀ g₁ g₂ x, act (g₁ * g₂) x = act g₁ (act g₂ x)
  ga_one : ∀ x, act 1 x = x

variable {G : Type*} [Group G] {X : Type*} [GroupAction G X]



-- /-!
-- ## Example
-- -/

example (g1 g2 : G) (x : X) :
  GroupAction.act (g1 * g2) x = GroupAction.act g1 (GroupAction.act g2 x) :=
  GroupAction.ga_mul g1 g2 x
-- The symmetric group on X is Equiv.Perm X
-- Its elements act on X by function application







/-!

## Theorem: permutation representation

Let X be a G-set.

1. For each g ∈ G, define σ_g : X → X by σ_g(x) = g • x.
   Then σ_g is a permutation of X, i.e. a bijection X → X.

2. Define a map φ : G → Sym X by φ(g) = σ_g.
   Then φ is a group homomorphism.

Moreover, for all g ∈ G and x ∈ X, we have φ(g)(x) = g • x.
-/

-- theorem groupActionToPermRepresentation
--   {G : Type*} [Group G]
--   {X : Type*} [GroupAction G X]
--   (actX : GroupAction G X) :
--   ∃ (φ : G → Equiv.Perm X), -- Equiv.Perm X is Lean's Sym X
--     (∀ g : G, ∀ x : X, φ g x = actX.act g x) ∧
--     (∀ g1 g2 : G, φ (g1 * g2) = φ g1 * φ g2) ∧
--     (φ 1 = 1) := by
--   sorry

/-- The action map `sigma g : X → X` given by `x ↦ g • x`. -/
def sigma (g : G) : X → X :=
  fun x => GroupAction.act g x

/-- The permutation of `X` induced by `g`, with inverse given by `g⁻¹`. -/
def sigmaPerm (g : G) : Equiv.Perm X :=
  { toFun := sigma g
    invFun := sigma g⁻¹
    left_inv := by
      intro x
      calc
        -- Use the action axiom, then cancel with g⁻¹.
        GroupAction.act g⁻¹ (GroupAction.act g x) =
            GroupAction.act (g⁻¹ * g) x := by
          simpa using (GroupAction.ga_mul g⁻¹ g x).symm
        _ = GroupAction.act (1 : G) x := by
          -- simpa using
          --   congrArg (fun t => GroupAction.act t x) (inv_mul_cancel g)
          simp
        _ = x := GroupAction.ga_one x
    right_inv := by
      intro x
      calc
        -- Symmetric calculation for g · (g⁻¹ · x).
        GroupAction.act g (GroupAction.act g⁻¹ x) =
            GroupAction.act (g * g⁻¹) x := by
          simpa using (GroupAction.ga_mul g g⁻¹ x).symm
        _ = GroupAction.act (1 : G) x := by
          -- simpa using
          --   congrArg (fun t => GroupAction.act t x) (mul_inv_cancel g)
          simp
        _ = x := GroupAction.ga_one x }

/-- The permutation representation `phi : G → Equiv.Perm X` induced by the action. -/
def phi (g : G) : Equiv.Perm X :=
  sigmaPerm g

/-! The action and the permutation representation agree on elements of `X`. -/
lemma phi_apply (g : G) (x : X) : phi g x = GroupAction.act g x := rfl


-- lemma phi_mul : ∀ (g₁ g₂ : G), phi (g₁ * g₂) = phi g₁ * phi g₂ := by
  -- sorry -- error
  /-- `phi` is multiplicative: `phi (g₁ * g₂) = phi g₁ * phi g₂`. -/
  lemma phi_mul (g₁ g₂ : G) :
    phi (X := X) (g₁ * g₂) = phi (X := X) g₁ * phi (X := X) g₂ := by
    -- Extensionality: it suffices to prove equality on each x.
    apply Equiv.ext
    intro (x : X)
    calc
      phi (g₁ * g₂) x = GroupAction.act (g₁ * g₂) x := rfl
      _ = GroupAction.act g₁ (GroupAction.act g₂ x) := GroupAction.ga_mul g₁ g₂ x


/-! `phi 1` is the identity permutation. -/
lemma phi_one : phi (1 : G) = (1 : Equiv.Perm X) := by
  apply Equiv.ext
  intro (x : X)
  calc
    phi (1 : G) x = GroupAction.act (1 : G) x := rfl
    _ = x := GroupAction.ga_one x
    _ = (1 : Equiv.Perm X) x := by
      simp [Equiv.Perm.one_apply]

/-! The action yields a permutation representation. -/
theorem groupActionToPermRepresentation :
  ∃ (φ : G → Equiv.Perm X),
    (∀ g x, φ g x = GroupAction.act g x) ∧
    (∀ g₁ g₂, φ (g₁ * g₂) = φ g₁ * φ g₂) ∧
    (φ 1 = 1) := by
  -- Compact term:
  exact ⟨phi, ⟨phi_apply, ⟨phi_mul, phi_one⟩⟩⟩
  --
  -- -- Expanded proof (step-by-step)(Powered by github copilot):
  -- refine ⟨phi, ?_⟩ -- provide φ = phi
  -- refine ⟨phi_apply, ?_⟩ -- provide φ g x = g • x
  -- refine ⟨phi_mul, ?_⟩ -- provide φ (g₁ * g₂) = φ g₁ * φ g₂
  -- exact phi_one -- provide φ 1 = 1

-- Moreover, for all g ∈ G and x ∈ X, we have φ(g)(x) = g • x.
theorem groupActionToPermRepresentation_apply
  {g : G} {x : X} -- ∀ g ∈ G and x ∈ X
  (φ : G → Equiv.Perm X) -- given φ
  (hφ : (∀ g x, φ g x = GroupAction.act g x)) : -- we have φ(g)(x) = g • x
  φ g x = GroupAction.act g x :=
  hφ g x -- by definition of hφ


/-!
# stabilizer (isotropy subgroup)
## Theorem: Let X be a G-set. Then Gₓ  , is a subgroup of G for each x ∈ X.
Let X be a G-set. Let x € X and g € G . I t will be important to know when g x = x . W e
let Gₓ = { g ∈  G | g x = x } , X_g = { x ∈  X | g x = x } .
-/
/-- The stabilizer set `G_x = { g ∈ G | g • x = x }`. -/
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
theorem stabilizerSet_isSubgroup (x : X) :
    ∃ H : Subgroup G, (H : Set G) = stabilizerSet (G := G) (X := X) x := by
  refine ⟨stabilizer (G := G) (X := X) x, rfl⟩


-- /-- The stabilizer set is the carrier of a subgroup of `G`. -/
-- theorem stabilizerSet_isSubgroup' (x : X) :
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
--   Classical.choose (stabilizerSet_isSubgroup' (G := G) (X := X) x)
-- theorem stabilizer_carrier_via_choice (x : X) :
--     (stabilizer_via_choice (G := G) (X := X) x : Set G) = stabilizerSet (G := G) (X := X) x :=
--   Classical.choose_spec (stabilizerSet_isSubgroup' (G := G) (X := X) x)
