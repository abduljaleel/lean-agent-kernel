import BookCode.Types

namespace BookCode.Ch04
open BookCode

/-- Tiny typeclass demo. The real `Capable` (indexed by a tool name) lives in Ch16. -/
class Gated (α : Type) where
  name : String
  allowed : α → Bool

instance : Gated ToolCall where
  name := "tool"
  allowed c := !c.name.isEmpty && c.name != "shell"

def gate {α : Type} [Gated α] (x : α) : Except String α :=
  if Gated.allowed x then
    .ok x
  else
    .error s!"denied by {Gated.name α}"

def readCall : ToolCall :=
  { name := "read", args := .obj [("path", .str "README.md")] }

def shellCall : ToolCall :=
  { name := "shell", args := .str "rm -rf /" }

#eval gate readCall
#eval gate shellCall

end BookCode.Ch04
