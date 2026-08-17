import BookCode.Ch02
import BookCode.Ch06
import BookCode.Ch16
import BookCode.Ch18
import BookCode.Axioms
import BookCode.SidebarFalse

namespace BookCode.Audit

/-- Public theorems this package is willing to advertise. -/
def publicTheorems : List String :=
  [ "BookCode.Ch02.two"
  , "BookCode.Ch02.everyNatEqItself"
  , "BookCode.Ch02.add_zero"
  , "BookCode.Ch02.zero_add"
  , "BookCode.Ch06.safe_of_ok"
  , "BookCode.Ch06.safe_implies_isOk"
  , "BookCode.Ch06.zero_add"
  , "BookCode.Ch06.add_zero"
  , "BookCode.Ch16.checkReadFilePre_sound"
  , "BookCode.Ch17.replayStep (example failingVerify)"
  , "BookCode.Ch18.selfTest_ok"
  , "BookCode.Ch18.checkReadFilePre_sound"
  , "BookCode.naiveTableAttest_inconsistent"
  , "BookCode.naiveLlmExec_inconsistent"
  ]

/-- Axioms this package is allowed to depend on.
    Kernel theorems such as `add_zero` / `checkReadFilePre_sound` / `selfTest_ok`
    must not grow this set. `tableAttest` and `llmExecAttest` are Level-3
    residual assumptions; they mint only a *fixed* interpretation. -/
def expectedAxioms : List String :=
  [ "propext"
  , "Quot.sound"
  , "Classical.choice"
  , "BookCode.tableAttest"
  , "BookCode.llmExecAttest"
  ]

def axiomSetOk (axioms : List String) : Bool :=
  axioms.all (fun a => expectedAxioms.contains a)

end BookCode.Audit
