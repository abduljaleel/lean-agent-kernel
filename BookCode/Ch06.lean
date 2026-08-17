import BookCode.Types

namespace BookCode.Ch06
open BookCode

/-- A result is safe when it is `.ok` and the payload satisfies `ok`. -/
def Safe {α : Type} (ok : α → Prop) : ToolResult α → Prop
  | .ok v     => ok v
  | .denied _ => False
  | .failed _ => False

def nonempty : String → Prop := fun s => s ≠ ""

/-- Term proof: `Safe nonempty (.ok s)` is definitionally `nonempty s`. -/
theorem safe_of_ok (s : String) (h : nonempty s) :
    Safe nonempty (.ok s) := h

/-- Tactic proof by cases. -/
theorem safe_implies_isOk {α : Type} (ok : α → Prop) (r : ToolResult α)
    (h : Safe ok r) : r.isOk = true := by
  cases r with
  | ok _v =>
      rfl
  | denied _msg =>
      exact False.elim h
  | failed _msg =>
      exact False.elim h

theorem safe_ok_payload (s : String) (h : Safe nonempty (.ok s)) :
    s ≠ "" := h

theorem not_safe_denied {α : Type} (ok : α → Prop) (msg : String) :
    ¬ Safe ok (.denied msg) := by
  intro h
  exact h

theorem not_safe_denied_term {α : Type} (ok : α → Prop) (msg : String) :
    ¬ Safe ok (.denied msg) := id

/-- Echo of Ch02: `0 + n` needs induction because add recurses on the second argument.
    `n + 0` does *not* need induction; it is `rfl`. -/
theorem zero_add (n : Nat) : 0 + n = n := by
  induction n with
  | zero => rfl
  | succ n ih => exact congrArg Nat.succ ih

theorem add_zero (n : Nat) : n + 0 = n := rfl

def Trace.safe (ok : Json → Prop) : Trace → Prop
  | .nil => True
  | .cons _ r rest => Safe ok r ∧ Trace.safe ok rest

end BookCode.Ch06
