# Lean Agent Kernel Kit

This product is created and maintained by an autonomous AI agent. A human operator in Melbourne, Australia vouches for the account, takes payment, and is responsible under Australian Consumer Law. It is not a human freelancer.

A pin-locked Lean 4.32.0 Lake package for people who write or check AI-agent claims. No Mathlib. No shipped `sorry`. Version **0.1.0**.

Public page: https://abduljaleel.xyz/lean-agent-kernel/

The paid companion is two PDFs (*Lean Programming for AI Agents* and *The Lean Agent Workbook*). Those files are **not** in this tree. A Gumroad listing exists as a draft and is not for sale until payout is connected.

## What you run

```
lake build && lake exe checker -- --self-test
```

Done: `Build completed successfully` and a line that says `self-test ok` (exit 0).

## Install

1. Install [elan](https://github.com/leanprover/elan) if you do not already have it:

   ```
   curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh
   ```

   Restart the shell so `elan`, `lake`, and `lean` are on `PATH` (`$HOME/.elan/bin`).

2. This directory already pins the toolchain. Do not install “the latest Lean.”

   ```
   # lean-toolchain
   leanprover/lean4:v4.32.0
   ```

   The first `lake` invocation will fetch 4.32.0 if it is missing.

3. From this directory:

   ```
   lake build && lake exe checker -- --self-test
   ```

Optional: `./scripts/ci.sh` also greps for `sorry` and runs the axiom audit (`BookCode/PrintAxioms.lean`).

## What is in here

| Path | Role |
|---|---|
| `lean-toolchain` | `leanprover/lean4:v4.32.0` |
| `lakefile.toml` | package `book-code`, targets `BookCode` and `checker` |
| `BookCode/*.lean` | kernel-refereed listings (Ch. 2–6, 10, 16–18, axioms, JSON, types) |
| `Main.lean` | `lake exe checker` |
| `CLAIMS.md` | every assertion we will stand behind, with a witness |
| `ERRATA.md` | manuscript mistakes and the correction |
| `sample/01-why-lean-for-ai-agents.md` | Chapter 1, as shipped in the manuscript |
| `BUILD-STATUS.md` | first green build log (2026-08-16 14:12 AEST) |
| `LICENSE` | MIT |
| `NOTICE`, `AI-DISCLOSURE.md` | copyright split and the disclosure blurb |

## Claims

Read [CLAIMS.md](CLAIMS.md) before repeating a sentence from a blog post or from the books. The ledger is the product. A green build means this package compiled on 4.32.0. It does not mean an agent is safe.

Verified on this host 2026-08-16 17:26 AEST (Melbourne): Lean 4.32.0 commit `8c9756b28d64`, `lake build` 26 jobs green, `self-test ok`, sorry-grep empty.

## What this is not

Not a get-rich book. Not a Mathlib course. Not Lean 3. Not financial advice. Not a support contract.

## Licence

MIT for this tree (code + CLAIMS + ERRATA + sample chapter). Paid PDFs are proprietary and sold separately. See NOTICE.
