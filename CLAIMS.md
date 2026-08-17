# Claims ledger
Verified: 15
Corrected: 17
Removed: 5

Pin: leanprover/lean4:v4.32.0. Release notes: https://lean-lang.org/doc/reference/latest/releases/v4.32.0/

Every prose assertion touched in the kernel-refereed revision has a row. Verified rows are facts we checked on 4.32.0 (commit 8c9756b) or against the release notes. Corrected rows are manuscript claims that were rewritten. Removed rows are false claims that were cut rather than replaced in that slot.

| ID | Claim | Witness | Status |
|---|---|---|---|
| C-01 | Lean 4.32.0 makes the new `do` elaborator the default (`backward.do.legacy` false). | https://lean-lang.org/doc/reference/latest/releases/v4.32.0/ | verified |
| C-02 | The 4.32 `do` surface requires `Pure`; `return` inside `(← do …)` escapes the outer block; `do match` is non-dependent by default. | same release notes, #13305 / #13912; Ch. 17 “mvcgen for loops” | verified |
| C-03 | `Nat.add` recurses on the second argument. | `#print Nat.add` on v4.32.0; `BookCode/Ch02.lean` | verified |
| C-04 | `n + 0 = n` is definitional; `rfl` closes it. | `BookCode/Ch02.add_zero`; live `example (n : Nat) : n + 0 = n := rfl` | corrected |
| C-05 | `0 + n = n` is not definitional; induction + `congrArg Nat.succ` closes it, axiom-free. | `BookCode/Ch02.zero_add`; `#print axioms` → none | verified |
| C-06 | `n + 0 = n` requires induction because addition recurses on the first argument. | contradicted by C-03/C-04; cut from Ch. 2 | removed |
| C-07 | `#synth Add String` fails; `#synth Append String` succeeds. | live 4.32.0 probe; `BookCode/Ch02.lean` comment | verified |
| C-08 | `#eval twice "na"` yields `"nana"` via `Add String`. | `#synth Add String` fails; listing cut | removed |
| C-09 | `twice [Add α]` is honest for `Int`. | `BookCode/Ch02.lean` `#eval twice (3 : Int)` → 6 | verified |
| C-10 | `\| while` as a `NodeKind` constructor parses on 4.32.0. | `BookCode/Ch17.lean`; live probe exit 0 | verified |
| C-11 | `checkReadFilePre_sound` is a closed unfold+split; no `sorryAx`. | `BookCode/Ch16.lean`; `#print axioms` → propext, Classical.choice, Quot.sound | corrected |
| C-12 | A `Capable "read_file"` instance may cite `checkReadFilePre_sound` without inheriting `sorryAx`. | `BookCode/Ch16.lean` instance; axiom audit | corrected |
| C-13 | Naive `tableAttest (e) (p : Prop)` proves `False` by `p := False`. | `BookCode/SidebarFalse.naiveTableAttest_inconsistent` | verified |
| C-14 | Fixed `interp` + `axiom tableAttest (e) : e.tool = "table_lookup" → interp e` does not quantify over a free `Prop`. | `BookCode/Axioms.lean`; `#print axioms mint` → propext, tableAttest | corrected |
| C-15 | Naive `llmExecAxiom (spec) (s) : pre → ∃ r s', post` is inconsistent (`post := False`). | `BookCode/SidebarFalse.naiveLlmExec_inconsistent` | verified |
| C-16 | `llmExecAttest` is indexed by a concrete `RecordedRun` and a fixed `interpRun`. | `BookCode/Axioms.lean`; Ch. 17 listing | corrected |
| C-17 | `replayStep sweLoop failingVerify = false`. | `BookCode/Ch17.lean` example `by decide`; `Ch18.selfTest_ok` | verified |
| C-18 | `checkNodePost` is in scope before `replayStep`. | `BookCode/Ch17.lean` declaration order; `lake build` | corrected |
| C-19 | `parseJson` and `hash` are total functions in the package (`String → Json`, `String → UInt64`). | `BookCode/Json.lean` | corrected |
| C-20 | `drainQuota` compiles; its Hoare triple is EXERCISE 17.4, not a shipped `sorry`. Invariant: `s.counter ≤ quota ∧ acc.length ≤ calls.length`. | `BookCode/Ch17.lean` EXERCISE 17.4 comment | corrected |
| C-21 | Public theorems' axiom set ⊆ {propext, Classical.choice, Quot.sound, tableAttest, llmExecAttest}. | `scripts/ci.sh` axiom audit; `BookCode/PrintAxioms.lean` | verified |
| C-22 | `selfTest_ok` is `by decide` and does not depend on `native_decide`. | `#print axioms BookCode.Ch18.selfTest_ok` | corrected |
| C-23 | `lake build && lake exe checker -- --self-test` is green on v4.32.0 with no Mathlib. | `scripts/ci.sh` | verified |
| C-24 | `1 + 1 = 2` is `rfl`. | `BookCode/Ch02.two` | verified |
| C-25 | The core package pin is `leanprover/lean4:v4.32.0`. | `book-code/lean-toolchain`; Ch. 18 | verified |
| C-26 | Chapter 6's `zero_add` (`0 + n = n` by induction) was already the identity that needs a proof. | `06-propositions-tactics.md`; `BookCode/Ch06.lean` | verified |
| C-27 | Chapter 10 `simp` examples that taught “needs a lemma” now use `0 + n = n` / `Nat.zero_add`. | `10-automation-grind-aesop-mvcgen.md` | corrected |
| C-28 | `verifyFixPost` is defined before `nodeSpec`; the log test is `log.contains "FAILED" = false` (`Prop`), not a raw `Bool`. | Ch. 17 listing; `BookCode/Ch17.lean` | corrected |
| C-29 | `expectedAxioms` is `[propext, Classical.choice, Quot.sound, tableAttest, llmExecAttest]`. | Ch. 16 `decideVerdict` listing | corrected |
| C-30 | Chapter 18 `checkReadFilePre_sound` is closed (unfold + split), not a remaining hole. | Ch. 18 listing; `BookCode/Ch18.lean` re-export | corrected |
| C-31 | Edited chapters name the attestation axiom `llmExecAttest`, not `llmExecAxiom` (except the naive-form lesson). | Ch. 2, 16, 17, 18 | corrected |
| C-32 | Chapter 2 `add_zero` is `rfl`; `zero_add` is the induction. | `BookCode/Ch02.lean` | corrected |
| C-33 | Chapter 2 staged `rfl` failure is `0 + n = n`. | `02-types-terms-and-the-kernel.md` | corrected |
| C-34 | Chapter 6 states that `n + 0 = n` is definitional and `zero_add` is the induction. | `06-propositions-tactics.md` | corrected |
| C-35 | “The `sorry` is a hole we will not ship.” | cut from Ch. 16; theorem is closed | removed |
| C-36 | “The `sorry` in `checkReadFilePre_sound` is a hole you close before you mint `Verified`.” | cut from Ch. 18 | removed |
| C-37 | A compiled `sorry` after `mvcgen [drainQuota, callWithQuota]` ships in the package. | cut; EXERCISE 17.4 comment only | removed |
