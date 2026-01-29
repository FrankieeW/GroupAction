/-
Title: Examples.lean
Project: Project 1 (Group Actions)
Author: Frankie Feng-Cheng WANG
Date: June 2026
Copyright (c) 2026 Frankie Feng-Cheng WANG. All rights reserved.
Repository: https://github.com/FrankieeW/GroupAction
-/
import GroupAction.Defs
import GroupAction.Basic
import Mathlib.Data.ZMod.Basic
import Mathlib.GroupTheory.SpecificGroups.Dihedral

-- /-!
-- ## Example

/-! ## Examples -/
/-- The symmetric group `Equiv.Perm X` acts on `X` by evaluation. -/
instance permGroupAction (X : Type*) : GroupAction (Equiv.Perm X) X :=
  { act := fun g x => g x
    ga_mul := by
      intro g1 g2 x
      rfl
    ga_one := by
      intro x
      rfl }

theorem permGroupAction_faithful (X : Type*) :
  GroupAction.faithful (G := Equiv.Perm X) (X := X) :=
by
  intro g₁ g₂ h
  ext x
  exact h x

theorem permGroupAction_transitive
  (X : Type*) [DecidableEq X] :
  GroupAction.transitive (G := Equiv.Perm X) (X := X) :=
by
  intro x₁ x₂
  refine ⟨Equiv.swap x₁ x₂, ?_⟩
  simp [GroupAction.act]
--rmk: `[DecidableEq X]` is needed for `Equiv.swap`

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
      simp }

instance subgroupAsGSetConjugation {G : Type*} [Group G] (H : Subgroup G) : GroupAction H H :=
  {
    act := fun h g => h * g * h⁻¹

    ga_mul := by
      intro g₁ g₂ g₃
      -- one step
      -- simp [mul_assoc]
      -- in detail
      simp
      -- goal state: g₁ * g₂ * g₃ * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃ * g₂⁻¹) * g₁⁻¹
      rw [← mul_assoc g₁]
      -- goal state: g₁ * g₂ * g₃ * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃) * g₂⁻¹ * g₁⁻¹
      rw [mul_assoc g₁ g₂]
      -- goal state:  g₁ * (g₂ * g₃) * (g₂⁻¹ * g₁⁻¹) = g₁ * (g₂ * g₃) * g₂⁻¹ * g₁⁻¹
      rw [← mul_assoc]
    ga_one := by
      intros
      simp }



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
      simp }
#check vectorSpaceAsCStarSet 3
-- instance vectorSpaceAsRStarSet (n : ℕ) :
--     GroupAction (ℝˣ) (Fin n → ℝ) :=
--   -- using vectorSpaceAsCStarSet
instance vectorSpaceAsUnitSet
  (α : Type*) [Monoid α]
  (n : ℕ) :
  GroupAction (αˣ) (Fin n → α) :=
{ act := fun r v => fun i => (r : α) * v i
  ga_mul := by
    intros r1 r2 v
    ext i
    simp [mul_assoc]
  ga_one := by
    intro v
    ext i
    simp }
  #check vectorSpaceAsUnitSet ℝ 3
  #check vectorSpaceAsUnitSet ℂ 3





-- open DihedralGroup

/-! ## Examples: Dihedral group D4 acting on vertices, sides, midpoints of a square -/
/-!
Let `D4 = DihedralGroup 4` be the symmetry group of the square.
We index the vertices, sides, and midpoints by `ZMod 4`.
Rotations are encoded as `r i`, reflections as `sr i`.
The action on `ZMod 4` is defined by
`r i • x = x - i` (rotation by `i` quarter turns) and
`sr i • x = i - x` (reflection across the axis indexed by `i`).
-/
abbrev D4 := DihedralGroup 4
abbrev Vertex := ZMod 4
abbrev Side := ZMod 4
abbrev Midpoint := ZMod 4

def d4Act (g : D4) (x : ZMod 4) : ZMod 4 :=
  match g with
  -- Rotation r_i: x ↦ x - i
  | DihedralGroup.r i => x - i
  -- Reflection s_i: x ↦ i - x
  | DihedralGroup.sr i => i - x

instance d4ActionZMod4 : GroupAction D4 (ZMod 4) :=
  { act := d4Act
    ga_mul := by
      intro g1 g2 x
      cases g1 <;> cases g2 <;>
        simp [d4Act, sub_eq_add_neg] <;> ring
    ga_one := by
      intro x
      simp [DihedralGroup.one_def, d4Act, -DihedralGroup.r_zero]
    }

instance d4CenterAction : GroupAction D4 PUnit :=
  { act := fun _ _ => PUnit.unit
    ga_mul := by
      intros
      rfl
    ga_one := by
      intros
      rfl }

/-! ## Example: Symmetric group S₃ acting on {1,2,3} -/
/-!
The symmetric group on 3 elements acts transitively on `Fin 3`.
This is the standard example of a transitive group action.
-/
abbrev S3 := Equiv.Perm (Fin 3)

instance s3ActionFin3 : GroupAction S3 (Fin 3) :=
  { act := fun g x => g x
    ga_mul := by
      intro g1 g2 x
      rfl
    ga_one := by
      intro x
      rfl }

theorem s3Action_transitive : GroupAction.transitive (G := S3) (X := Fin 3) :=
  permGroupAction_transitive (Fin 3)

#check s3ActionFin3
#check s3Action_transitive
