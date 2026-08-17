import BookCode.Types
import BookCode.Ch16
import BookCode.Ch17

namespace BookCode.Ch18
open BookCode
open BookCode.Ch16
open BookCode.Ch17

def selfTest : Bool :=
  replayStep sweLoop failingVerify == false

theorem selfTest_ok : selfTest = true := by decide

/-- Re-export of the closed Ch16 theorem. No second proof. -/
theorem checkReadFilePre_sound (c : ToolCall)
    (h : checkReadFilePre c = true) : readFilePre c :=
  Ch16.checkReadFilePre_sound c h

end BookCode.Ch18
