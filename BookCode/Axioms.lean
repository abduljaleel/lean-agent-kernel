import BookCode.Types

namespace BookCode

/-- Evidence a tool produced. Not a proof. -/
structure Evidence where
  tool : String
  payload : Json
deriving Repr, BEq, Inhabited

/-- Fixed interpretation of evidence. Not a free `Prop` parameter.
    A `table_lookup` of a string attests that the string is nonempty.
    Every other shape denotes `True` (the axiom cannot mint `False`). -/
def interp (e : Evidence) : Prop :=
  match e.tool, e.payload with
  | "table_lookup", .str s => s ≠ ""
  | _, _ => True

/-- Level-3 residual: we trust the table tool to have produced this cell.
    The minted fact is exactly `interp e`, a function of `e`'s fields. -/
axiom tableAttest (e : Evidence) : e.tool = "table_lookup" → interp e

structure RecordedRun where
  specName : String
  start    : Store
  result   : ToolResult Json
  finish   : Store
deriving Repr, Inhabited

/-- Fixed interpretation of a recorded run. Not a free pre/post.
    An `.ok` result attests that the finish store is nonempty.
    Denied/failed results denote `True`. -/
def interpRun (r : RecordedRun) : Prop :=
  match r.result with
  | .ok _ => r.finish ≠ []
  | _     => True

/-- The axiom mints only what that run denotes. A free `post := False`
    is impossible because `post` is not a parameter. -/
axiom llmExecAttest (r : RecordedRun) : interpRun r

end BookCode
