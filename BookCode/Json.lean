/-
Pedagogical JSON and small total helpers used by later chapters.
No Mathlib. Everything here is total.
-/
namespace BookCode

/-- Pedagogical JSON. Production code can use `Lean.Json`. -/
inductive Json where
  | null
  | bool : Bool → Json
  | num  : Int → Json
  | str  : String → Json
  | arr  : List Json → Json
  | obj  : List (String × Json) → Json
deriving Repr, BEq, Inhabited

def Json.getObj : Json → List (String × Json)
  | .obj kvs => kvs
  | _        => []

def Json.lookup (j : Json) (k : String) : Option Json :=
  j.getObj.lookup k

def Json.containsKey (j : Json) (k : String) : Bool :=
  (j.lookup k).isSome

def Json.containsValue (j : Json) (v : Json) : Bool :=
  match j with
  | .arr xs => xs.contains v
  | .obj kvs => kvs.any (fun ⟨_, x⟩ => x == v)
  | _ => j == v

/-- Minimal total parser. Never partial: unknown input becomes `.str s`. -/
def parseJson (s : String) : Json :=
  if s == "null" then
    .null
  else if s == "true" then
    .bool true
  else if s == "false" then
    .bool false
  else if s.startsWith "\"" && s.endsWith "\"" && s.length >= 2 then
    .str ((s.drop 1).dropEnd 1).copy
  else
    .str s

/-- Polynomial rolling hash: fold `acc * 31 + char`. -/
def hash (s : String) : UInt64 :=
  s.foldl (fun acc c => acc * 31 + c.val.toUInt64) 0

def isValidURL (j : Json) : Bool :=
  match j with
  | .str s => s.startsWith "http"
  | _      => false

def isNonEmptyString (j : Json) : Bool :=
  match j with
  | .str s => s != ""
  | _      => false

end BookCode
