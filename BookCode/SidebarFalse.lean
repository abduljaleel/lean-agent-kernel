import BookCode.Axioms

namespace BookCode

/-!
No axioms in this file. These theorems show that a *hypothesis* of the
naive (free-`Prop`) attestation type is already inconsistent.
-/

/-- The naive table axiom takes a free `Prop` and is therefore explosive. -/
theorem naiveTableAttest_inconsistent
    (tableAttest : (e : Evidence) → (p : Prop) → e.tool = "table_lookup" → p) : False :=
  tableAttest { tool := "table_lookup", payload := Json.null } False rfl

/-- The naive LLM-exec axiom takes a free postcondition and is explosive. -/
theorem naiveLlmExec_inconsistent
    (llmExecAxiom :
      (pre : Store → Prop) →
      (post : Store → ToolResult Json → Store → Prop) →
      (s : Store) → pre s → ∃ r s', post s r s') : False :=
  match llmExecAxiom (fun _ => True) (fun _ _ _ => False) [] True.intro with
  | ⟨_r, _s', h⟩ => h

end BookCode
