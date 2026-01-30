/-
Title: Permutation.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/
-/
import GroupAction.Defs
import Mathlib.GroupTheory.Perm.Basic

/-!
## Theorem: permutation representation

Let `X` be a `G`-set.

1. For each `g ∈ G`, define `σ_g : X → X` by `σ_g(x) = g • x`.
   This map is a permutation of `X` (a bijection).
2. Define `φ : G → Sym X` by `φ(g) = σ_g`.
   This map is a group homomorphism.

Moreover, for all `g ∈ G` and `x ∈ X`, we have `φ(g)(x) = g • x`.
-/

variable {G : Type*} [Group G] {X : Type*} [GroupAction G X]

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
      intro x
      -- Step 1: combine `g⁻¹` and `g` using the action axiom.
      calc
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
      -- Step 1: combine `g` and `g⁻¹` using the action axiom.
      calc
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
  
#lint
