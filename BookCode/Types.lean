import BookCode.Json

namespace BookCode

structure ToolCall where
  name : String
  args : Json
deriving Repr, BEq, Inhabited

inductive ToolResult (α : Type) where
  | ok     : α → ToolResult α
  | denied : String → ToolResult α
  | failed : String → ToolResult α
deriving Repr, BEq, Inhabited

def ToolResult.isOk {α : Type} : ToolResult α → Bool
  | .ok _ => true
  | _     => false

inductive Trace where
  | nil
  | cons : ToolCall → ToolResult Json → Trace → Trace
deriving Repr, BEq, Inhabited

def Trace.length : Trace → Nat
  | .nil => 0
  | .cons _ _ t => t.length + 1

def Trace.calls : Trace → List ToolCall
  | .nil => []
  | .cons c _ t => c :: t.calls

def Trace.results : Trace → List (ToolResult Json)
  | .nil => []
  | .cons _ r t => r :: t.results

/-- Evidence the workflow has accumulated. Keys are write-set names. -/
abbrev Store := List (String × Json)

def Store.get (s : Store) (k : String) : Option Json :=
  s.lookup k

def Store.put (s : Store) (k : String) (v : Json) : Store :=
  (k, v) :: s.filter (fun ⟨k', _⟩ => k' != k)

def Store.keys (s : Store) : List String :=
  s.map (·.1)

end BookCode
