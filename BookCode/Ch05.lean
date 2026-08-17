import BookCode.Types

namespace BookCode.Ch05
open BookCode

/-- Agent monad: a trace in `StateT`, effects in `IO`. Lean 4.32 requires `Pure`. -/
abbrev AgentM := StateT Trace IO
abbrev AgentEM := ExceptT String (StateT Trace IO)

def record (c : ToolCall) (r : ToolResult Json) : AgentM Unit := do
  let t ← get
  set (Trace.cons c r t)
  pure ()

def stubTool (c : ToolCall) : IO (ToolResult Json) := do
  pure (.ok (.str c.name))

def agentStep (c : ToolCall) : AgentM (ToolResult Json) := do
  let r ← stubTool c
  record c r
  pure r

/-- A small fuelled loop. The final `pure` is required on 4.32. -/
def agentLoop : Nat → List ToolCall → AgentM (List (ToolResult Json))
  | 0, _ => pure []
  | _fuel+1, [] => pure []
  | fuel+1, c :: cs => do
      let r ← agentStep c
      let rest ← agentLoop fuel cs
      pure (r :: rest)

def plan (goal : String) : StateM Nat ToolCall := do
  let n ← get
  set (n + 1)
  pure { name := "echo", args := .str goal }

def plannedCall (goal : String) : ToolCall :=
  (plan goal).run' 0

def deny (reason : String) : AgentEM Unit := do
  throw reason

end BookCode.Ch05
