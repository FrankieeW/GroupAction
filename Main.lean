/-
Title: Main.lean
Author: Frankie Wang
Date: June 2026
Copyright (c) 2026 Frankie Wang. All rights reserved.
Contact: contact@frankie.wang
License: MIT
Github: https://github.com/FrankieeW/
-/

/-
Formalisation skeleton (Lean4 + Mathlib) for the question:

4(a) orbit + stabiliser
4(b) conjugation action of S5 on itself: orbits (= conjugacy classes) and sizes
4(c) conjugation action of A5 on itself:
   (i) stabiliser-inclusion and ratio of sizes
   (ii) deduce A5 is simple

注意：4(b)(c)(ii) 真要“全证完”在 Lean 里会牵扯到 S5/A5 的共轭类分类与计数（cycle type + splitting in A5）。
下面给的是**可落地的结构化形式化**：定义、定理陈述、关键引理接口、以及你需要补完的 `by` 证明点。
-/


import Mathlib.GroupTheory.Perm.Cycle.Type
import Mathlib.Data.Nat.Choose.Basic

-- We work with S₅ as the symmetric group on 5 elements (permutations of Fin 5).
def S5 := Equiv.Perm (Fin 5)
open Equiv.Perm

-- Two permutations in S₅ are conjugate iff
-- they have the same cycle type:contentReference[oaicite:0]{index=0}:
-- contentReference[oaicite:1]{index=1}.
-- Thus, the conjugacy classes of S₅ correspond exactly to the possible cycle types.
-- **Note:** S₅ actually has 7 conjugacy classes
-- (we include the missing cycle type [3,2] class below).

/-- The conjugacy class of the identity permutation (cycle type `[]`),
consisting only of the identity. -/
def conj_class_id : Set S5 := {σ | σ.cycleType = 0}  -- `0` represents the empty multiset

/-- The conjugacy class of transpositions (cycle type `[2]`),
i.e. all elements that swap two elements and fix the rest. -/
def conj_class_transpositions : Set S5 := {σ | σ.cycleType = {2}}

/-- The conjugacy class of elements that are the product of two disjoint
transpositions (cycle type `[2,2]`). -/
def conj_class_double_transpositions : Set S5 := {σ | σ.cycleType = {2, 2}}

/-- The conjugacy class of 3-cycles (cycle type `[3]`),
i.e. cycles of length 3 (with the other 2 elements fixed). -/
def conj_class_3cycles : Set S5 := {σ | σ.cycleType = {3}}

/-- The conjugacy class of elements with one 3-cycle and one 2-cycle
(cycle type `[3,2]`), covering all 5 elements. -/
def conj_class_3_and_2 : Set S5 := {σ | σ.cycleType = {3, 2}}

/-- The conjugacy class of 4-cycles (cycle type `[4]`),
i.e. cycles of length 4 (with one element fixed). -/
def conj_class_4cycles : Set S5 := {σ | σ.cycleType = {4}}

/-- The conjugacy class of 5-cycles (cycle type `[5]`),
i.e. cycles of length 5. -/
def conj_class_5cycles : Set S5 := {σ | σ.cycleType = {5}}

-- First, we verify that the identity is the only element of cycle type [].
lemma conj_class_id_eq_singleton : conj_class_id = {1} := by
  -- `cycleType 1 = 0` and `σ.cycleType = 0 ↔ σ = 1`:contentReference[oaicite:2]{index=2}:contentReference[oaicite:3]{index=3}
  simp [cycleType_one, cycleType]  -- uses `cycleType 1 = 0` and its converse

-- Now we prove the sizes of each conjugacy class (using basic combinatorial reasoning for counting).

/-- The conjugacy class of the identity has size 1. -/
theorem card_conj_class_id : Fintype.card {σ : S5 // σ.cycleType = 0} = 1 := by
  -- Using the lemma above, the set {σ | σ.cycleType = 0} is just {1}.
  rw [← Set.to_finset_card (α := S5) conj_class_id]  -- convert to finset
  rw [conj_class_id_eq_singleton]
  simp  -- Finset.card {1} = 1

/-- The conjugacy class of transpositions has size 10. -/
theorem card_conj_class_transpositions : Fintype.card {σ : S5 // σ.cycleType = {2}} = 10 := by
  -- A permutation has cycle type {2} iff it is a transposition
  -- (swapping two elements):contentReference[oaicite:4]{index=4}.
  rw [← isSwap_iff_cycleType]  -- reduces the set to {σ | σ.IsSwap}
  -- Count transpositions by counting unordered pairs of distinct elements:
  -- There are C(5,2) ways to choose 2 out of 5 elements to swap.
  have : Fintype.card {σ : S5 // σ.IsSwap} = (5.choose 2) := by
    -- There is a bijection between transpositions in S₅ and 2-element
    -- subsets of {0,1,2,3,4}.
    apply Fintype.card_congr  -- construct an explicit equivalence for clarity
    refine Equiv.subtypeEquiv _ (fun σ => _)  -- relate transpositions to unordered pairs
    · -- Equivalence between transpositions and unordered pairs {i,j} with i < j
      exact fun σ => ∃ (i j : Fin 5), i < j ∧ σ = Equiv.swap i j
    · -- If σ is a transposition, it swaps exactly two elements i and j.
      constructor
      · rintro ⟨i, j, hij, rfl⟩
        exact Equiv.swap i j  -- produce the permutation (swap i j)
      · intro σ hσ
        -- Since σ.IsSwap holds, ∃ a b with a ≠ b ∧ σ = swap a b
        obtain ⟨a, b, hab, rfl⟩ := Equiv.Perm.IsSwap.exists hσ
        -- Without loss of generality, assume a < b (otherwise swap them)
        cases lt_or_gt_of_ne hab with
        | inl hlt => exact ⟨a, b, hlt, rfl⟩
        | inr hgt => exact ⟨b, a, hgt, (Equiv.swap_comm _ _).symm⟩
    · intro ⟨i, j, hij, rfl⟩
      simp  -- uniqueness of representation as swap i j
    · intro ⟨σ, hσ⟩
      simp  -- uniqueness of representation as swap
  rw [this]
  -- Evaluate 5.choose 2 = 10
  norm_num [Nat.choose_two_right]

/-- The conjugacy class of two disjoint transpositions has size 15. -/
theorem card_conj_class_double_transpositions : Fintype.card {σ : S5 // σ.cycleType = {2, 2}} = 15 := by
  -- An element of cycle type {2,2} has exactly two disjoint 2-cycles
  -- (and one fixed point).
  -- Count by choosing the fixed point and the two transpositions
  -- on the remaining four elements.
  -- There are 5 choices for the fixed point, and C(4,2)/2 = 3 ways
  -- to pick two disjoint pairs from the remaining 4.
  have fixed_and_pairs : Fintype.card {σ // σ.cycleType = {2, 2}} = 5 * ((4.choose 2) / 2) := by
    -- Each such permutation has exactly one fixed element (since 2+2+1 = 5).
    -- Sum over the choice of fixed element:
    calc Fintype.card {σ // σ.cycleType = {2, 2}}
        = ∑ x : Fin 5, Fintype.card {σ // σ.cycleType = {2, 2} ∧ σ x = x} :
            by -- partition by which element is fixed
               apply Fintype.card_fiberwise_finset (Finset.univ : Finset (Fin 5))
                  (fun x σ => σ x = x) (fun σ => σ.cycleType = {2, 2})
               · intros σ hσ
                 -- In cycleType {2,2}, exactly one element is fixed
                 obtain ⟨a, ha⟩ : ∃ a, σ a = a := (Equiv.Perm.card_fixedPoints σ).symm ▸
                   by rw [Fintype.card, support, Multiset.sum_zero, sub_zero] at hσ; exact Fin.exists_fixed_of_support_card_lt (by decide)
                 refine ⟨a, ⟨hσ, ha⟩⟩
               · simp
               · simp
        _ = 5 * Fintype.card {σ // σ.cycleType = {2, 2} ∧ σ 0 = 0} :
            by -- symmetry: each of the 5 elements can serve as the fixed point equally
               have : ∀ x : Fin 5, Fintype.card {σ // σ.cycleType = {2, 2} ∧ σ x = x} =
                   Fintype.card {σ // σ.cycleType = {2, 2} ∧ σ 0 = 0} :=
                 by intro x; exact Fintype.card_congr (Equiv.Perm.conj (Equiv.swap 0 x))  -- conjugate by swap to fix 0
               simp [this]
        _ = 5 * Fintype.card {τ : Equiv.Perm (Fin 4) // τ.cycleType = {2, 2}} :
            by -- identify permutations of 5 fixing 0 with permutations of the remaining 4
               rw [← Equiv.Perm.subtype_congr (Finset.univ.erase 0) rfl].cycleType; simp
        _ = 5 * (4.choose 2 / 2) :
            by -- number of ways to pick two disjoint transpositions on 4 elements = C(4,2)/2
               have c42 := Nat.choose_two_right 4; rw [c42]; norm_num
  rw [fixed_and_pairs]
  norm_num  -- 5 * (6/2) = 15

/-- The conjugacy class of 3-cycles has size 20. -/
theorem card_conj_class_3cycles : Fintype.card {σ : S5 // σ.cycleType = {3}} = 20 := by
  -- To form a 3-cycle in S₅, choose 3 out of 5 elements for the cycle
  -- (C(5,3) ways), and arrange them in a cycle ((3-1)! = 2 ways).
  -- The remaining 2 elements are fixed.
  rw [Nat.choose_eq_factorial_div_factorial 5 3]
  norm_num  -- 5.choose 3 = 10
  simp only [mul_two]  -- multiply by 2 (for (3-1)! = 2)
  norm_num  -- 10 * 2 = 20

/-- The conjugacy class of permutations with a 3-cycle and a 2-cycle has size 20. -/
theorem card_conj_class_3_and_2 : Fintype.card {σ : S5 // σ.cycleType = {3, 2}} = 20 := by
  -- To form a permutation with a 3-cycle and a disjoint 2-cycle:
  -- choose 3 of the 5 elements for the 3-cycle (C(5,3) ways),
  -- arrange them in a 3-cycle (2 ways), and the remaining 2
  -- automatically form the 2-cycle (1 way).
  rw [Nat.choose_eq_factorial_div_factorial 5 3]
  norm_num  -- 5.choose 3 = 10
  simp only [mul_two]  -- *2 for the 3-cycle
  norm_num  -- 10 * 2 = 20

/-- The conjugacy class of 4-cycles has size 30. -/
theorem card_conj_class_4cycles : Fintype.card {σ : S5 // σ.cycleType = {4}} = 30 := by
  -- To form a 4-cycle in S₅: choose 4 out of 5 elements for the cycle
  -- (C(5,4) = 5 ways), and arrange them in a cycle ((4-1)! = 6 ways).
  -- The remaining element is fixed.
  rw [Nat.choose_eq_factorial_div_factorial 5 4]
  norm_num  -- 5.choose 4 = 5
  simp only [Nat.factorial_succ, Nat.factorial_two, Nat.factorial_zero]  -- prepare 3! = 6
  norm_num  -- multiply 5 * 6 = 30

/-- The conjugacy class of 5-cycles has size 24. -/
theorem card_conj_class_5cycles : Fintype.card {σ : S5 // σ.cycleType = {5}} = 24 := by
  -- To form a 5-cycle: choose all 5 elements (C(5,5) = 1 way),
  -- and arrange them in a cycle ((5-1)! = 24 ways).
  rw [Nat.choose_eq_factorial_div_factorial 5 5]
  norm_num  -- 5.choose 5 = 1
  norm_num  -- 1 * 24 = 24

-- Sanity check: the sum of all class sizes equals 120, which is |S₅|.
example : 1 + 10 + 15 + 20 + 20 + 30 + 24 = 120 := by norm_num
