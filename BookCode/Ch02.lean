/-
Chapter 2: types, terms, and the kernel.

Kernel-checked facts on Lean 4.32.0 (this machine):
* `Nat.add` recurses on the *second* argument.
* `n + 0 = n` is definitional (`rfl` succeeds).
* `0 + n = n` is *not* definitional (`rfl` fails); prove it by induction.
-/
namespace BookCode.Ch02

def first {α : Type} (x _y : α) : α := x

def twice [Add α] (x : α) : α := x + x

#eval twice (3 : Int)
-- 6
--
-- `#eval twice "na"` does *not* work: there is no `Add String`.
-- Strings concatenate with `++` (`Append String`), not `+`.
--
-- Verbatim compiler error from `lean` on the snippet `#synth Add String`
-- (Lean 4.32.0, this machine):
--
--   failed to synthesize
--     Add String
--
--   Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
--
-- `#synth Append String` succeeds and reports `instAppendString`.

#check Fin 5
-- Fin 5 : Type

def three : Fin 5 := ⟨3, by omega⟩

def Repeat (α : Type) : Nat → Type
  | 0     => Unit
  | n + 1 => α × Repeat α n

def twoNats : Repeat Nat 2 :=
  (1, (2, ()))

def someFin : (n : Nat) × Fin (n + 1) :=
  ⟨4, ⟨2, by omega⟩⟩

theorem two : 1 + 1 = 2 := rfl

theorem everyNatEqItself : ∀ n : Nat, n = n :=
  fun _n => rfl

/-- Definitional: `Nat.add` recurses on the second argument, so `n + 0` reduces. -/
theorem add_zero (n : Nat) : n + 0 = n := rfl

/-- Not definitional. Recursion is on the second argument, which is `n` here. -/
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg Nat.succ ih

/-
The following example is *rejected* by Lean 4.32.0. Captured by compiling
the throwaway file

    example (n : Nat) : 0 + n = n := by rfl

Verbatim compiler error:

    Tactic `rfl` failed: The left-hand side
      0 + n
    is not definitionally equal to the right-hand side
      n

    n : Nat
    ⊢ 0 + n = n
-/

end BookCode.Ch02
