import BookCode.Types
import BookCode.Ch16

namespace BookCode.Ch17
open BookCode

inductive NodeKind where
  | task
  | step
  | while
  | parallel
deriving Repr, BEq, DecidableEq

structure NodeId where
  name : String
deriving Repr, BEq, DecidableEq, Inhabited

structure Node where
  id     : NodeId
  kind   : NodeKind
  reads  : List String
  writes : List String
  tool?  : Option String
deriving Repr

structure Edge where
  src : NodeId
  dst : NodeId
deriving Repr, BEq

structure Workflow where
  nodes  : List Node
  edges  : List Edge
  start  : NodeId
  finish : NodeId
deriving Repr

def Workflow.nodeIds (w : Workflow) : List NodeId :=
  w.nodes.map (·.id)

def Workflow.hasNode (w : Workflow) (id : NodeId) : Bool :=
  w.nodeIds.contains id

def Workflow.writtenBefore (w : Workflow) : List String :=
  w.nodes.flatMap (·.writes)

def structuralOk (w : Workflow) : Bool :=
  w.hasNode w.start && w.hasNode w.finish &&
    w.edges.all (fun e => w.hasNode e.src && w.hasNode e.dst) &&
    w.nodes.all (fun n =>
      n.reads.all (fun r => w.writtenBefore.contains r || n.writes.contains r)) &&
    w.nodes.all (fun n =>
      match n.tool? with
      | none => n.kind != .step
      | some _ => n.kind == .step)

def succs (w : Workflow) (id : NodeId) : List NodeId :=
  w.edges.filterMap (fun e => if e.src == id then some e.dst else none)

partial def reachable (w : Workflow) (from_ : NodeId) : List NodeId :=
  let rec go (seen : List NodeId) (frontier : List NodeId) : List NodeId :=
    match frontier with
    | [] => seen
    | n :: ns =>
        if seen.contains n then go seen ns
        else go (n :: seen) (succs w n ++ ns)
  go [] [from_]

def nid (s : String) : NodeId := ⟨s⟩

def sweLoop : Workflow where
  nodes := [
    { id := nid "explore",   kind := .step, reads := [],
      writes := ["repoMap", "bugReport"], tool? := some "list_dir" },
    { id := nid "reproduce", kind := .step, reads := ["bugReport"],
      writes := ["reproScript", "failingTest"], tool? := some "run_tests" },
    { id := nid "fix",       kind := .step, reads := ["failingTest", "repoMap"],
      writes := ["diff"], tool? := some "edit_file" },
    { id := nid "verify",    kind := .step, reads := ["diff", "failingTest"],
      writes := ["testLog", "verifyOk"], tool? := some "run_tests" },
    { id := nid "patch",     kind := .step, reads := ["diff", "verifyOk"],
      writes := ["prUrl"], tool? := some "open_pr" }
  ]
  edges := [
    ⟨nid "explore", nid "reproduce"⟩,
    ⟨nid "reproduce", nid "fix"⟩,
    ⟨nid "fix", nid "verify"⟩,
    ⟨nid "verify", nid "patch"⟩,
    ⟨nid "verify", nid "fix"⟩
  ]
  start := nid "explore"
  finish := nid "patch"

/-- Preconditions are computational; defined *before* `replayStep`. -/
def checkNodePre (n : Node) (s : Store) : Bool :=
  match n.id.name with
  | "explore"   => true
  | "reproduce" => isNonEmptyString (s.get "bugReport" |>.getD .null)
  | "fix"       => isNonEmptyString (s.get "failingTest" |>.getD .null)
  | "verify"    => isNonEmptyString (s.get "diff" |>.getD .null)
  | "patch"     => s.get "verifyOk" == some (.bool true) &&
                    isNonEmptyString (s.get "diff" |>.getD .null)
  | _           => false

/-- Postconditions are computational; defined *before* `replayStep`. -/
def checkNodePost (n : Node) (r : ToolResult Json) (s' : Store) : Bool :=
  match n.id.name with
  | "verify" =>
      match r with
      | .ok _ =>
          s'.get "verifyOk" == some (.bool true) &&
            match s'.get "testLog" with
            | some (.str log) => !(log.contains "FAILED")
            | _ => false
      | _ => false
  | "patch" =>
      match r with
      | .ok v => isValidURL v
      | _ => false
  | "explore" => isNonEmptyString (s'.get "bugReport" |>.getD .null)
  | "reproduce" => isNonEmptyString (s'.get "failingTest" |>.getD .null)
  | "fix" => isNonEmptyString (s'.get "diff" |>.getD .null)
  | _ => false

structure StepRecord where
  node     : NodeId
  call     : ToolCall
  result   : ToolResult Json
  storeIn  : Store
  storeOut : Store
deriving Repr

abbrev Trajectory := List StepRecord

def applyWrites (n : Node) (r : ToolResult Json) (s : Store) : Store :=
  match n.id.name, r with
  | "explore",   .ok v =>
      (s.put "repoMap" v).put "bugReport" (v.lookup "bug" |>.getD (.str "bug"))
  | "reproduce", .ok v =>
      (s.put "reproScript" v).put "failingTest" (v.lookup "test" |>.getD (.str "t"))
  | "fix",       .ok v => s.put "diff" v
  | "verify",    .ok v =>
      let log := (v.lookup "log").getD v
      let ok := match log with
        | .str s => !(s.contains "FAILED")
        | _      => false
      (s.put "testLog" log).put "verifyOk" (.bool ok)
  | "patch",     .ok v => s.put "prUrl" v
  | _, _ => s

def replayStep (w : Workflow) (rec : StepRecord) : Bool :=
  match w.nodes.find? (·.id == rec.node) with
  | none => false
  | some n =>
      checkNodePre n rec.storeIn &&
        rec.storeOut == applyWrites n rec.result rec.storeIn &&
        checkNodePost n rec.result rec.storeOut

def replay (w : Workflow) (tr : Trajectory) : Bool :=
  tr.all (replayStep w) &&
    (tr.getLast?.map (·.node) == some w.finish)

def failingVerify : StepRecord where
  node := nid "verify"
  call := { name := "run_tests", args := .obj [("suite", .str "tests/")] }
  result := .ok (.obj [("log", .str "tests/test_bill.py::test_refund FAILED")])
  storeIn := [("diff", .str "--- a/bill.py\n+++ b/bill.py\n")]
  storeOut := [
    ("diff", .str "--- a/bill.py\n+++ b/bill.py\n"),
    ("testLog", .str "tests/test_bill.py::test_refund FAILED"),
    ("verifyOk", .bool true)
  ]

example : replayStep sweLoop failingVerify = false := by decide

structure AgentState where
  counter : Nat
  log     : List String
deriving Repr, Inhabited

def callWithQuota (quota : Nat) (c : ToolCall) :
    StateM AgentState (ToolResult Json) := do
  let s ← get
  if s.counter ≥ quota then
    pure (.denied "quota")
  else
    set { s with
      counter := s.counter + 1
      log := c.name :: s.log }
    pure (.ok .null)

/-- Compiling function. The Hoare triple is left as EXERCISE 17.4, not compiled. -/
def drainQuota (quota : Nat) (calls : List ToolCall) :
    StateM AgentState (List (ToolResult Json)) := do
  let mut acc : List (ToolResult Json) := []
  for c in calls do
    let r ← callWithQuota quota c
    acc := r :: acc
    match r with
    | .denied _ => break
    | _         => pure ()
  pure acc.reverse

/-
EXERCISE 17.4
State and prove a Hoare triple for `drainQuota`. Suggested invariant:

    s.counter ≤ quota ∧ acc.length ≤ calls.length

In the Std.Do style (not compiled here; would need a loop invariant that
`grind` will not invent):

    example (quota : Nat) (calls : List ToolCall) :
        ⦃ fun s => ⌜s.counter = 0⌝ ⦄
        drainQuota quota calls
        ⦃ ⇓ rs s => ⌜s.counter ≤ quota ∧ rs.length ≤ calls.length⌝ ⦄ := by
      mvcgen [drainQuota, callWithQuota]
      -- you will be asked for a loop invariant
      -- invariant in prose: s.counter ≤ quota ∧ acc.length ≤ calls.length

Do not leave an unfinished tactic hole in compiled code.
-/

end BookCode.Ch17
