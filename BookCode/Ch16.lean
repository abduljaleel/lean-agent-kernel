import BookCode.Types
import BookCode.Axioms

namespace BookCode.Ch16
open BookCode

def underWorkspace (path : String) : Bool :=
  path.startsWith "/workspace/" && !(path.contains "..")

def readFilePre (c : ToolCall) : Prop :=
  c.name = "read_file" ∧
    ∃ path, c.args.lookup "path" = some (.str path) ∧ underWorkspace path = true

def readFilePost (_c : ToolCall) : ToolResult Json → Prop
  | .ok _     => True
  | .denied m => m ≠ ""
  | .failed _ => True

/-- Computational cousin of `readFilePre`. The exe checker runs this. -/
def checkReadFilePre (c : ToolCall) : Bool :=
  c.name == "read_file" &&
    match c.args.lookup "path" with
    | some (.str path) => underWorkspace path
    | _                => false

theorem checkReadFilePre_sound (c : ToolCall)
    (h : checkReadFilePre c = true) : readFilePre c := by
  unfold checkReadFilePre at h
  simp only [Bool.and_eq_true] at h
  obtain ⟨hname, hpath⟩ := h
  refine ⟨eq_of_beq hname, ?_⟩
  revert hpath
  cases c.args.lookup "path" with
  | none =>
      intro hpath
      simp at hpath
  | some j =>
      cases j with
      | str path =>
          intro hpath
          exact ⟨path, rfl, hpath⟩
      | null => intro hpath; simp at hpath
      | bool _ => intro hpath; simp at hpath
      | num _ => intro hpath; simp at hpath
      | arr _ => intro hpath; simp at hpath
      | obj _ => intro hpath; simp at hpath

structure Contract (α : Type) where
  pre  : ToolCall → Prop
  run  : (c : ToolCall) → (h : pre c) → IO (ToolResult α)
  post : ToolCall → ToolResult α → Prop

/-- Presence of an instance is permission. Absence is a failure to synthesise. -/
class Capable (name : String) where
  contract : Contract Json
  checkPre : ToolCall → Bool
  checkPre_correct :
    ∀ c, c.name = name → checkPre c = true → contract.pre c

def readFileContract : Contract Json where
  pre  := readFilePre
  run  := fun c _h => do
    match c.args.lookup "path" with
    | some (.str path) =>
        try
          let s ← IO.FS.readFile path
          pure (.ok (.str s))
        catch e =>
          pure (.failed (toString e))
    | _ =>
        pure (.denied "missing path")
  post := readFilePost

instance : Capable "read_file" where
  contract := readFileContract
  checkPre := checkReadFilePre
  checkPre_correct := by
    intro c _hn ht
    exact checkReadFilePre_sound c ht

/-- Mint the *fixed* interpretation of this evidence, not a free `Prop`. -/
theorem mint (e : Evidence) (h : e.tool = "table_lookup") : interp e :=
  tableAttest e h

inductive Verdict where
  | accept
  | reject (reason : String)
  | abstain (reason : String)
deriving Repr

def checkCall (c : ToolCall) : Verdict :=
  if c.name == "read_file" then
    if checkReadFilePre c then .accept
    else .reject "read_file precondition failed"
  else
    .abstain s!"unknown tool {c.name}"

def decodeToolCall (j : Json) : Option ToolCall :=
  match j.lookup "name" with
  | some (.str n) => some { name := n, args := (j.lookup "args").getD .null }
  | _             => none

end BookCode.Ch16
