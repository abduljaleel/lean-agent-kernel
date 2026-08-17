namespace BookCode.Ch10

-- `n + 0` is definitional on Lean 4.32 (`Nat.add` recurses on the second argument).
example (n : Nat) : n + 0 = n := by rfl

example (n : Nat) : n + 0 = n := by simp

-- `grind` is in core Lean 4.32; no Mathlib import is required for linear Nat goals.
example (used quota : Nat) (h : used < quota) :
    used + 1 ≤ quota := by
  grind

example (used quota : Nat)
    (h1 : used ≤ quota) (h2 : used ≠ quota) :
    used < quota := by
  grind

example (n : Nat) (h : n < 5) : n ≤ 4 := by
  grind

-- If `grind` were unavailable we would use `omega` instead:
--   example (n : Nat) (h : n < 5) : n ≤ 4 := by omega

end BookCode.Ch10
