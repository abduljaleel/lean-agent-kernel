import BookCode.Types

namespace BookCode.Ch03
open BookCode

inductive Action where
  | read   (path : String)
  | write  (path : String) (contents : String)
  | shell  (cmd : String)
  | finish (summary : String)
deriving Repr, Inhabited, BEq

def step : Action := .read "src/Main.lean"

def shouldRetry {α : Type} : ToolResult α → Bool
  | .ok _       => false
  | .denied _   => false
  | .failed msg => msg.startsWith "timeout" || msg.startsWith "429"

def listFiles : ToolCall :=
  { name := "list_dir", args := .obj [("path", .str "src")] }

def sampleResult : ToolResult Json :=
  .ok (.arr [.str "Main.lean"])

def sampleTrace : Trace :=
  .cons listFiles sampleResult .nil

def describe : Action → String
  | .read p      => s!"read {p}"
  | .write p _   => s!"write {p}"
  | .shell c     => s!"shell {c}"
  | .finish s    => s!"finish {s}"

#eval listFiles.name
#eval sampleTrace.length
#eval shouldRetry (sampleResult : ToolResult Json)
#eval describe step

end BookCode.Ch03
