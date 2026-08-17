# Errata — Lean Programming for AI Agents (kernel-refereed revision)

Pin: `leanprover/lean4:v4.32.0` (13 July 2026). No substitution. Release notes: https://lean-lang.org/doc/reference/latest/releases/v4.32.0/

Wrong quotes are taken from `/workspace/book-revision/DEFECTS.md` (verbatim manuscript text). Witnesses are files under `book-code/` unless noted.

Unedited chapters (`01`, `13`, `part-d-status`) still name `llmExecAxiom` as the published-paper identifier. The redesigned declaration lives in Chapters 16–18 as `llmExecAttest`.

---

### E-01 `n + 0 = n` is not definitional
- Location: Chapter 2, “Definitional versus propositional equality”
- Wrong: “It does not include `n + 0 = n` for symbolic `n`. That is a *propositional* equality, and you need a proof term.”
- Corrected: “It includes `n + 0 = n` for symbolic `n`, because `Nat.add` recurses on the *second* argument and the `0` clause returns `n`. It does not include `0 + n = n`.”
- Witness: `BookCode/Ch02.lean` (`add_zero`); live `example (n : Nat) : n + 0 = n := rfl`

### E-02 “recurses on the first argument”
- Location: Chapter 2, `add_zero` listing
- Wrong: “This does *not* close with rfl. Addition is defined by recursion on the first argument; `n` is not a constructor.”
- Corrected: “This *does* close with rfl. Addition is defined by recursion on the second argument; `0` is a constructor.” `theorem add_zero (n : Nat) : n + 0 = n := rfl`
- Witness: `BookCode/Ch02.lean`; `#print Nat.add` on v4.32.0

### E-03 “the kernel refuses `rfl`”
- Location: Chapter 2, after `add_zero`
- Wrong: “The model writes `rfl` because \"they are clearly equal.\" They are equal after a lemma, not by computation. The kernel refuses `rfl`.”
- Corrected: “The model writes `rfl` on `0 + n = n` because \"they are clearly equal.\" They are equal after a lemma, not by computation. The kernel refuses `rfl`. The fix is induction and `congrArg Nat.succ`.”
- Witness: `BookCode/Ch02.lean` (`zero_add`); captured `rfl` failure on `0 + n = n`

### E-04 staged `rfl` failure that is not a failure
- Location: Chapter 2, “`rfl` on a propositional equality”
- Wrong: “`-- error: tactic 'rfl' failed, equality is not definitional` / `example (n : Nat) : n + 0 = n := by rfl`” and “The Infoview still shows `⊢ n + 0 = n`. The model should induct or `simp`, not retry `rfl`.”
- Corrected: the staged failure is `example (n : Nat) : 0 + n = n := by rfl`. “The Infoview still shows `⊢ 0 + n = n`. The model should induct (`congrArg Nat.succ`) or `rw [Nat.zero_add]`, not retry `rfl`.”
- Witness: `BookCode/Ch02.lean` comment block quoting the 4.32.0 `rfl` error on `0 + n`

### E-05 `n + 0` as the “needs a lemma / simp” example
- Location: Chapter 6, “simp and simp?” / “induction”; Chapter 10, “`simp` is a rewrite normaliser”
- Wrong: Chapter 10: “It will turn `n + 0` into `n` and `Safe ok (.ok v)` into `ok v` if you give it the lemma.” Listings `example (n : Nat) : n + 0 = n := by simp` and `simp only [Nat.add_zero]` on `n + 0 + 0 = n`.
- Corrected: “It will turn `0 + n` into `n` if you give it `Nat.zero_add`… `n + 0 = n` is definitional — `rfl` closes it — and is the wrong example of \"needs simp.\"” Chapter 6 now states: “This is the identity that needs a proof. `n + 0 = n` is definitional — `rfl` closes it.”
- Witness: `BookCode/Ch02.lean` (`add_zero`, `zero_add`); `BookCode/Ch06.lean`

### E-06 `#eval twice "na"` / `Add String`
- Location: Chapter 2, instance-implicit `twice`
- Wrong: “`#eval twice \"na\"` / `-- \"nana\"`” and “`String` has an `Add` instance that concatenates.”
- Corrected: “`#eval twice (3 : Int)` / `-- 6`” and “`#synth Add String` fails. `#synth Append String` succeeds. Concatenation is `++`, not `+`.”
- Witness: `BookCode/Ch02.lean` comment quoting the live `#synth Add String` error

### E-07 `| while` constructor parses
- Location: Chapter 17, “From a call to a graph”; Chapter 18, `NodeKind`
- Wrong: DEFECTS claimed “A bare constructor `| while` is a parse error. It must be escaped (`| «while»`) or renamed (`| whileNode`).”
- Corrected: kept `| while`. “`| while` as a constructor *parses* on Lean 4.32.0 (commit 8c9756b). We tested it. Do not rename it on a rumour that `while` is reserved in this position.”
- Witness: `BookCode/Ch17.lean` (`NodeKind.while`); live 4.32.0 probe exit 0

### E-08 `replayStep` called `checkNodePost` before it was defined
- Location: Chapter 17, “Layer 3: trajectory replay”
- Wrong: “`replayStep` calls `checkNodePost` at line 349; `checkNodePost` is defined at line 351.”
- Corrected: `checkNodePost` is defined *before* `replayStep`. “Postconditions are computational; defined *before* `replayStep`.”
- Witness: `BookCode/Ch17.lean` declaration order; `lake build`

### E-09 `verifyFixPost` used before defined / `Bool` in `Prop`
- Location: Chapter 17, node specs
- Wrong: “`nodeSpec` mentions `verifyFixPost` at `:233`; the definition is at `:252`.” and “`!(log.contains \"FAILED\")` has type `Bool`. The surrounding `∧` / `match` is a `Prop`.”
- Corrected: `verifyFixPost` is defined before `nodeSpec`. The `Bool` test is written `log.contains "FAILED" = false`.
- Witness: `BookCode/Ch17.lean`; manuscript listing order

### E-10 `parseJson` was undefined
- Location: Chapter 16, checker `main`; Chapter 18, `Main.lean`
- Wrong: “`match decodeToolCall (parseJson raw) with`” with no definition; Chapter 18: “`-- parseJson is a stub you replace with Lean.Json.parse`”
- Corrected: total `parseJson : String → Json` shipped in the package. “Never partial: unknown input becomes `.str s`.”
- Witness: `BookCode/Json.lean`; `lake build`

### E-11 `hash` undefined / wrong type
- Location: Chapter 16, `decideVerdict`
- Wrong: “`else if hash r.statement != expectedHash then`” with `expectedHash : String` and no definition. “Prelude `hash` (from `Hashable`) returns `UInt64`.”
- Corrected: “`def hash (s : String) : UInt64 := s.foldl (fun acc c => acc * 31 + c.val.toUInt64) 0`” and `expectedHash : UInt64`.
- Witness: `BookCode/Json.lean`

### E-12 `checkReadFilePre_sound` left as `sorry`
- Location: Chapter 16, `readFilePre` / `checkReadFilePre`; Chapter 18, `Myagent/Tools.lean`
- Wrong: “`-- unfold, split on the match, close with grind or a short term proof` / `sorry`” and “The `sorry` is a hole we will not ship.” Chapter 18: “The `sorry` in `checkReadFilePre_sound` is a hole you close before you mint `Verified` about the *theorem*.”
- Corrected: “The theorem is closed: unfold the checker, split on the match, and the `Bool` becomes the `Prop`. There is no `sorry`.” Chapter 18 listing contains the same unfold+split proof. “`checkReadFilePre_sound` is closed.”
- Witness: `BookCode/Ch16.lean`; `BookCode/Ch18.lean` (re-export); `#print axioms` → `[propext, Classical.choice, Quot.sound]`

### E-13 `drainQuota` Hoare triple was a shipped `sorry`
- Location: Chapter 17, `mvcgen` for loops
- Wrong: “`mvcgen [drainQuota, callWithQuota]` / `-- you will be asked for a loop invariant; grind will not invent it` / `sorry`” and “The `sorry` is visible. … Shipping the `sorry` is a LAMP *pass*, not a *complete*.”
- Corrected: “**Exercise 17.4.** State and prove the Hoare triple for `drainQuota`. The invariant … is `s.counter ≤ quota ∧ acc.length ≤ calls.length`. The function compiles. The triple does not ship as a `sorry`.”
- Witness: `BookCode/Ch17.lean` EXERCISE 17.4 comment; `scripts/ci.sh` sorry-grep

### E-14 `tableAttest` quantified over an arbitrary `Prop`
- Location: Chapter 16, “EG-VAR at pedagogical scale”
- Wrong: “`axiom tableAttest (e : Evidence) (p : Prop) : e.tool = \"table_lookup\" → p`” and “`let _ : c.prop := tableAttest e c.prop h`” / “`#print axioms mint` will show `tableAttest`.”
- Corrected: “`def interp (e : Evidence) : Prop`” and “`axiom tableAttest (e : Evidence) : e.tool = \"table_lookup\" → interp e`.” Sidebar: “`example (e : Evidence) (h : e.tool = \"table_lookup\") : False := tableAttest_naive e False h`.” The kernel-facing gate is `interp_of_table`, not a discarded `let` on a `def`.
- Witness: `BookCode/Axioms.lean`; `BookCode/SidebarFalse.lean` (`naiveTableAttest_inconsistent`); `#print axioms BookCode.Ch16.mint`

### E-15 `llmExecAxiom` quantified over an arbitrary spec
- Location: Chapter 17, former “`llmExecAxiom`: an assumption you declare”
- Wrong: “`axiom llmExecAxiom (spec : NodeSpec) (s : Store) : spec.pre s → ∃ r s', spec.post s r s'`” and “When `llmExecAxiom verifySpec s` is uninhabited because `verifyFixPost` requires a passing test log …”
- Corrected: “`axiom llmExecAttest (r : RecordedRun) : interpRun r`” with a fixed `interpRun`. “An axiom is never uninhabited.” The naive form is shown as a lesson, not shipped: see `BookCode/SidebarFalse.lean`.
- Witness: `BookCode/Axioms.lean`; `BookCode/SidebarFalse.lean` (`naiveLlmExec_inconsistent`)

### E-16 `native_decide` on the self-test
- Location: Chapter 17, “Falsifying `verify_fix`”; Chapter 18, `selfTest`
- Wrong: `example : replayStep sweLoop failingVerify = false := by native_decide`
- Corrected: `by decide`. Chapter 18: `theorem selfTest_ok : selfTest = true := by decide`. Depends only on `propext`, `Classical.choice`, `Quot.sound`.
- Witness: `BookCode/Ch17.lean`; `BookCode/Ch18.lean`; `#print axioms BookCode.Ch18.selfTest_ok`
