import BookCode.Ch18

def main (args : List String) : IO UInt32 := do
  if args.contains "--self-test" then
    if BookCode.Ch18.selfTest then
      IO.println "self-test ok"
      pure 0
    else
      IO.println "self-test FAILED"
      pure 1
  else
    IO.println "usage: lake exe checker --self-test"
    pure 2
