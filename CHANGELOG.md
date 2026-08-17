# Changelog

## 0.1.0 — 2026-08-16

First packaged free core of **Lean Agent Kernel Kit**.

- Lake package on `leanprover/lean4:v4.32.0` (commit `8c9756b28d64`). No Mathlib.
- `lake build` green (26 jobs). `lake exe checker -- --self-test` prints `self-test ok`.
- Zero `sorry` in `*.lean`. Public theorems' axiom set ⊆ {propext, Classical.choice, Quot.sound, tableAttest, llmExecAttest} per CLAIMS C-21.
- CLAIMS.md: 15 verified / 17 corrected / 5 removed (kernel-refereed revision, 2026-08-16).
- ERRATA.md shipped next to the code that witnesses each row.
- Sample chapter: `sample/01-why-lean-for-ai-agents.md`.
- MIT licence. Paid PDFs are not in this tree.

Re-verified on the packaging host 2026-08-16 17:26 AEST (Melbourne) against `/workspace/book-code`.
