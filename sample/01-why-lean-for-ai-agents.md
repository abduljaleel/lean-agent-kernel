# Chapter 1 — Why Lean for AI Agents

Lean 4 is a dependently typed language *and* a small-kernel proof assistant. You will use it both ways: to *write* programs — planners, decoders, checkers — and to *judge* programs — specs, contracts, certificates. Those two jobs share a syntax because they share a meaning. A proof that `n ≠ 0` is a value you can hand to a division function. An agent that must produce that value cannot shrug and divide anyway.

The 2024–2026 window changed the story from "AI that writes Lean proofs" to "Lean as the kernel that decides whether an agent's claim is allowed to stand." This chapter is that story, the three trust levels the rest of the book never conflates, and just enough toolchain to run `lake init`.

## Fluent, wrong, unchecked

A language model is a next-token engine with a chat template. In an agent it is wrapped in tools: `read_file`, `write_file`, `run_command`, `search`. The model emits a tool call that looks like a decision. The runtime executes it. The observation comes back as more tokens. The model continues.

The failure mode is not that the model is silent. The failure mode is that the model is *articulate*. It can explain a bad plan in the same register it explains a good one. It can write a test that encodes the bug. It can apologize and repeat the mistake with different variable names. It can claim it checked a property that it only restated.

Consider a loop that is allowed to patch a billing service. The model is told: never apply a discount that exceeds the remaining balance; never emit a refund without a prior charge id; never call `charge` twice for the same idempotency key. These are not style rules. They are invariants. In English they are paragraphs. In a unit test they are a handful of cases the model itself can edit. In a type that the compiler erases, they are comments that got promoted to names.

An agent that has been wrong in production has a signature. The trace looks competent. The tool calls are well-formed JSON. The commit message is in the house style. The invariant is still broken. Someone later writes a postmortem that says the model "should have been given a better prompt."

Prompts do not check. They bias. A better prompt makes the next mistake more polite.

What you want is a place in the loop where a claim becomes a term, and a term is either well-typed or it is not. The model can try again. It cannot negotiate with the checker.

Ordinary host-language types are not that place. TypeScript will stop an agent from passing a string where a number is required, if the agent actually runs `tsc` and if the types were not `any`. Rust will stop it from moving a value twice. Those checks are real. They are also the wrong grain for the claims agents get wrong.

The claims look like this:

- This tool returned *n* items, and the next call indexes `i` with `i < n`.
- This refund refers to a charge that exists and has not already been refunded.
- This plan uses only tools the policy allows, in an order the policy allows.
- This JSON blob is not just "an object" but a `Charge` with a non-empty id and a non-negative amount.

Some of that is a better host-language type. Most of it is a *property of values* that a simply-typed language will not mention. Dependent types let a type mention a value. `Fin n` is a natural number known to be less than `n`. A function

```lean
def nth {α : Type} {n : Nat} (xs : Vector α n) (i : Fin n) : α :=
  xs[i]
```

does not throw. It does not return `Option`. The caller must supply a proof that `i` is in range, or a value that carries that proof. An agent that wants to index must produce the proof. If it cannot, the kernel refuses the program. The runtime path that would have panicked does not exist.

That is a different kind of API. The type is not a hint to the IDE. The type is the permission to run.

## The 2024–2026 arc

Lean was created in 2013 at Microsoft Research by Leonardo de Moura. Lean 4.0 shipped on 8 September 2023 as a self-hosted compiler. The Lean FRO (Focused Research Organization) was founded in July 2023 under Convergent Research, with a five-year mission of scalability, usability, documentation, automation, and self-sustainability. de Moura is now Senior Principal Applied Scientist at AWS Automated Reasoning and remains Chief Architect of the FRO. Sebastian Ullrich is Head of Engineering. By 2026 the funders include Alex Gerko / XTX Markets, Amazon Automated Reasoning (the largest FRO donation, July 2026), Harmonic, Simons, Sloan, and Merkin. Zulip has had more than 10,000 members since 2024. Reservoir at https://reservoir.lean-lang.org/ is the package index.

None of that would have made this book necessary. The AI systems did.

**AlphaProof**, with AlphaGeometry 2, reached IMO 2024 silver: 4 of 6 problems, 28 of 42 points. The architecture was AlphaZero-style reinforcement learning on millions of autoformalized problems, plus test-time RL. The Nature paper appeared on 12 November 2025 (https://doi.org/10.1038/s41586-025-09833-y). Pushmeet Kohli of DeepMind has stated on lean-lang.org that Lean is the verification backbone of their math AI. The operational fact for this book: the silver medal was a *formal* silver. The kernel accepted the terms.

**Aristotle** (Harmonic) and **Seed-Prover** (ByteDance Seed) both reached IMO 2025 gold-level formal solutions, 5 of 6 problems. Aristotle combines Lean search with an informal-lemma formalizer and a geometry engine (Uklid); the paper is arXiv:2510.01346, and the IMO 2025 artifacts live at https://github.com/harmonic-ai/IMO2025. Tudor Achim of Harmonic has likewise stated on lean-lang.org that Lean is the verification backbone. Seed-Prover 1.5 treats Lean as a *tool* inside an agentic RL loop (arXiv:2507.23726, arXiv:2512.17260). The architectural split matters: Aristotle is search plus informal lemmas; Seed-Prover 1.5 is an agent that calls Lean. Both still end at the kernel.

**OpenAI's August 2026 certificates** are the public "kernel-as-artifact" moment. On 1 August 2026 OpenAI published ten decade-open results, each a Lean 4.32.0 + Mathlib certificate, Apache-2.0, at https://github.com/openai/ten-proofs. The advertised check is one line:

```
lake exe cache get && lake build All
```

That is not a blog post about a model being careful. It is a repository you can clone, pin, and rebuild. The commentary around `ten-proofs` is also the right warning: a Lean certificate is a binary artifact. It compiles or it does not. It does not, by itself, prove that the formal statement matches the informal claim.

**Comparator** and **Lean Eval** launched in June 2026. Comparator is a sandboxed judge: export a certificate and re-check it independently. Lean Eval is a public submission leaderboard of hard formalisation problems. The **Lean Kernel Arena** (April 2026) benchmarks independent proof checkers. These exist because the community stopped treating "our Lean said yes" as the last word.

Around the same window, research systems started treating the kernel as a referee for *agents*, not just for olympiad math. Lean4Agent models workflows and trajectories as dependent types (arXiv:2606.06523). LAMP splits Planner / Builder / Verifier and distinguishes *pass* (no errors) from *complete* (no errors, no `sorry`) (arXiv:2606.28841). EG-VAR makes the Lean kernel the only minter of `Verified` claims, via explicit tool-attestation axioms (arXiv:2607.12650). None of these is a drop-in safe-agent SDK as of August 2026. All of them assume you can write Lean and read a kernel verdict.

Open provers — DeepSeek-Prover-V2 (7B and 671B, arXiv:2504.21801), Kimina-Prover (arXiv:2504.11354), Goedel-Prover-V2 (arXiv:2508.03613), InternLM2.5-StepProver (arXiv:2410.15700) — made step-search and whole-proof generation a thing you can run, not only a thing you can read about. LeanDojo-v2, Lean Copilot, the community REPL, LeanInteract, and Pantograph are the APIs this book will actually implement against. Chapter 13 is the map. This chapter only needs the moral: the default formal target for AI mathematics is Lean 4, and the emerging referee for agent claims is the same kernel.

## Industrial witnesses

Math AI is the loud story. Production systems were already using Lean as a spec language.

**AWS Cedar** is an authorization policy language. The spec is in Lean; the production engine is Rust; the two are differentially tested. Byron Cook (AWS) and Emina Torlak (Cedar) have stated on lean-lang.org that Lean is the verification backbone of that stack. The hybrid is the one you can ship in 2026: Lean does not have to be the hot path. It has to be the spec the hot path is not allowed to drift from.

**Aeneas**, from Microsoft Research, translates Rust into Lean. In July 2026 that pipeline reached SymCrypt, Microsoft's cryptographic library. The direction is the opposite of Cedar — implementation first, spec extracted — but the referee is the same.

**SampCert** (PLDI 2025) is a verified differential-privacy sampler. It is the existence proof that a Lean-checked artifact can be a library, not a paper.

The pattern across all three: Lean is in the trust story, not necessarily in the request path. An agent system can take the same shape. Write the contract in Lean. Compile a checker. Let Python call the checker. Keep the model on the untrusted side of the kernel.

## Three trust levels

A Lean file that "succeeds" can mean three different things. The rest of the book never conflates them.

**1. Kernel-checked term.** Strongest. The elaborator produced a term, the kernel accepted it, and the term has the type you asked for. Relative to the axioms you have chosen and the correctness of that kernel, the statement holds. This is what `lake build` of a `sorry`-free file with no unexpected axioms is claiming.

**2. Statement match.** Did we formalise the *right* claim? The kernel will happily verify a weaker theorem. Autoformalization of undergraduate math tops out around 45% on current benches (Poiroux et al., EMNLP 2025); research-level text without context still fails. Comparator, BEq+, and a human reading `#print` of the statement are the checks. OpenAI's `ten-proofs` commentary is about this gap. A certificate of the wrong theorem is a compiled lie.

**3. Attestation axioms.** We *assume* a tool or an LLM step established a postcondition. EG-VAR and Lean4Agent are honest about this: `llmExecAxiom` is an assumption you declare, not a theorem you hide. Residual error is formalization error, not kernel error. If you mint `Verified` from an attestation axiom and then forget to list the axiom, you have performed a marketing trick, not a proof.

The product rule, stated once so later chapters can point at it:

- **Accept** only if `lake build` / the REPL reports no errors, there is no `sorry` and no `declaration uses 'sorry'` warning, `#print axioms` shows only axioms you have accepted, and the statement hash matches the challenge.
- **Reject** on kernel error, type mismatch, or `sorry`.
- **Abstain** when formalization is uncertain. Never mint `Verified` from an LLM judge alone.
- Re-check in a sandbox. Do not trust the generator's Lean.

A slogan you can put in a system prompt: *a Lean certificate is a binary artifact. It compiles or it does not. It does not, by itself, prove that the formal statement matches the informal claim.*

## The kernel is the part you do not trust the model about

Lean is a large system. There is an elaborator, a tactic framework, a metaprogramming API, a compiler to C, a language server, and a growing standard library. Almost all of that is *not* the trusted computing base you care about when an agent is the author.

The trusted part is the kernel. The kernel implements a small type theory (calculus of constructions plus inductive types plus quotient types). It checks that a term has a type, under a context, up to the definitional equality of that theory. It does not search. It does not run `simp`. It does not care that a tactic was called `grind` or that a model wrote a comment saying "obvious." It checks the term the elaborator produced.

The trust story, stated as an engineer would state it:

1. You choose axioms. For most programs the axioms are those of Lean's type theory plus whatever you `axiom` yourself. Do not add axioms. If you do, you have enlarged the kernel's idea of truth.
2. The elaborator, tactics, and the model are untrusted. They may produce anything.
3. Whatever they produce is elaborated into a term.
4. The kernel checks the term.
5. If you want a second opinion, you replay the compiled artifact through an independent checker. The Lean Kernel Arena exists because this is now a public sport, not a footnote.

A large tactic proof is not a large trusted object. It is a program that *constructs* a term. The term is what matters. Agents change the economics: a human will not write a 4,000-line tactic script for a one-off invariant. An agent will, if you let it, and it will do so at 3 a.m. after a failing test. You do not want to review that script as if it were prose. You want it to collapse to a kernel-checkable term, and you want the term's *type* to be the invariant you actually care about.

If the type is `True`, you have checked nothing. If the type is `RefundSafe charge refund`, you have checked whatever `RefundSafe` means. Designing that type is the work. The kernel only enforces the work you did.

```lean
-- Checked, and worthless:
theorem patch_ok : True := trivial

-- The right shape. Until `sorry` is gone, it is a wish.
-- After `sorry` is gone, it is a fact about *these* definitions.
theorem refund_le_charge (c : Charge) (r : Refund)
    (h : r.chargeId = c.id) :
    r.amount ≤ c.amount := by
  sorry
```

`sorry` type-checks *anything*. An agent that can emit it will. Chapter 2 treats `sorry`, `axiom`, `unsafe`, `partial`, and `noncomputable` as product decisions: each expands the trusted computing base. The one-file certificate in that chapter is a proposition, a real proof, a `sorry` fake, and a CI snippet that rejects the fake.

## Why Lean 4, specifically

There are other proof assistants. Coq, Agda, Isabelle, and F★ can sit in a similar story. This book is about Lean 4 because of a combination that matters for agents.

**It is a programming language.** Lean 4 was rewritten to be a fast, usable language with a real compiler to C, `do` notation, a package manager (Lake), and metaprogramming in Lean itself. You can write the agent tool in Lean. You can write the checker in Lean. You can write the tactic that searches for a proof in Lean. One toolchain. The CADE-28 paper is the design document.

**The kernel is small relative to the system.** Tactics are Lean programs. They are not a second trusted language. An agent that writes a tactic is writing an untrusted term-producer. That is the correct status for agent output.

**The community library is large.** Mathlib is more than 1.5 million lines (the reference introduction; module-system talks cite about 2 million). For agent work, `Init` plus `Std` plus a few packages is often enough. When you need algebra, graphs, or a wall of lemmas, they exist and they are already checked. Always copy Mathlib's `lean-toolchain`. Always run `lake exe cache get` after adding Mathlib. Building from source is hours.

**The editor protocol is good, and the agent protocol is better.** Goal states, hover types, and error messages are machine-readable through the language server and the REPL. An agent that cannot see a goal is guessing. Do not build a gym on LSP cursor positions; that is Chapter 11's hard recommendation. Use the community REPL or Pantograph.

**Metaprogramming is ordinary.** You will need to generate definitions, inspect expressions, and write custom tactics that encode *your* invariants. In Lean 4 that is library code. Chapters 8 and 9 live there.

**Automation is now a closer you can name.** `grind` has been in core since 4.22.0 (14 August 2025). Aesop is the community best-first search. `mvcgen` in `Std.Do` turns a `do` program into Hoare verification conditions. Chapter 10 is the decision guide. You do not need it to write `main`.

Lean 3 is obsolete. The Mathlib port completed in July 2023. Do not use it. `begin` / `end` tactic blocks are a tell that you have opened the wrong book.

## What this book will not teach

A short exclusion list, so you do not wait for chapters that are not coming.

- **Lean manufacturing / Toyota lean.** Homonym. Zero overlap.
- **Lean 3.** Mentioned only as a migration footnote.
- **A generic Haskell-style functional-programming course.** `do`, monads, and FBIP appear only as needed to write agents and tactics.
- **A Mathematics in Lean course.** Mathlib is a dependency, not a curriculum.
- **A deep Coq / Isabelle / Agda comparison.** The paragraph above is the comparison.
- **Training a 671B prover from scratch.** DeepSeek-Prover-V2, Kimina, and Seed-Prover are cited. GPU recipes are not reproduced.
- **Writing exploits, malware, or attack proofs-of-concept.** Formal *defensive* specs of tool contracts are in scope. Offensive help is not.

The honest 2026 line, which Chapter 18 will repeat: you can *ship* a kernel-checked tool-contract layer and a `mvcgen`'d planner. You cannot yet ship "the agent formalises arbitrary English and the kernel makes it true."

## Install just far enough to run `lake init`

elan is the toolchain manager. It installs `lean` and `lake` and selects the version a project asks for. Projects pin a version in a `lean-toolchain` file. You should not install "a Lean" globally and hope. You should install elan, then let each package declare its toolchain.

On Linux or macOS:

```bash
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh
source $HOME/.elan/env
```

On Windows, use the elan PowerShell installer from https://elan.lean-lang.org/elan-init.ps1, or follow https://lean-lang.org/install/manual/.

Accept the default toolchain when elan asks. This book pins **Lean 4.32.0** (13 July 2026). *Functional Programming in Lean* is tested against the same tag. *Theorem Proving in Lean 4* already tracks 4.33.0. If you depend on Mathlib, Batteries, Aesop, or LeanDojo, copy *that* library's `lean-toolchain`. Release cadence is roughly monthly. `lake update` can jump the compiler; treat it as a deliberate upgrade.

You also need `git` and `curl`. Lake fetches dependencies with git. Distribution packages that offer a system `elan` or `lake` are often stale. Prefer the official elan install.

```bash
elan --version
lake --version
lean --version
```

You should see a Lean 4 version string. If `lake` is missing from `PATH`, you did not source `~/.elan/env` in this shell.

Create the first package:

```bash
lake init hello
cd hello
lake build
lake exe hello
```

`lake init` writes a `lakefile.toml` (or a `lakefile.lean`), a `lean-toolchain` pin, a library root, and a `Main.lean`. A typical `Main.lean` is already an agent-shaped program: it takes arguments and returns an exit code.

```lean
def main (args : List String) : IO UInt32 := do
  IO.println s!"hello, {args}!"
  return 0
```

`lake build` type-checks the library and compiles the executable. A type error is a failed build. That is the cheapest kernel loop you will ever have: the agent edits a file, you run `lake build`, you feed the error back.

For a single file with no imports you can also run `lean --run Hello.lean`. A package is what you ship. A lone `.lean` file in an empty folder will fight you.

Install the official **Lean 4** extension by `leanprover` in VS Code (or VSCodium / Cursor via Open VSX). The extension starts the language server and shows the Infoview. Neovim users should use `lean.nvim`. The Infoview is not optional. Lean without goal display is a language you cannot see. Open the *folder* of the Lake package, not a single file from a random path. The server reads `lean-toolchain` and the lakefile from the project root.

A minimal sanity check: save this inside the package and hover `#eval`.

```lean
#eval 1 + 1
```

You want `2`, no errors. If the Infoview is empty, the toolchain is still installing or the file is not in a project the server understands.

You do not need Mathlib yet. When you do:

```bash
lake +leanprover-community/mathlib4:lean-toolchain new MyMathlibProject math
cd MyMathlibProject
lake exe cache get
```

`lake exe cache get` saves hours. Building Mathlib from source is how weekends disappear. The wiki at https://github.com/leanprover-community/mathlib4/wiki/Using-mathlib4-as-a-dependency is the current procedure.

Python talking to Lean is Chapter 11. The community REPL is https://github.com/leanprover-community/repl. LeanInteract (`pip install lean-interact`, v0.11.5 as of July 2026) wraps it and supports Lean through `v4.32.0-rc1` via a backported REPL fork. You do not need it to finish Part I.

## Clone `ten-proofs` and build it

The August 2026 certificates are the first homework that is not a toy.

```bash
git clone https://github.com/openai/ten-proofs
cd ten-proofs
# lean-toolchain in this repo is Lean 4.32.0; elan will fetch it
lake exe cache get
lake build All
```

If the build succeeds, you have independently replayed ten kernel-checked artifacts. If it fails, the usual causes are a toolchain skew, a missing cache, or a network that cannot see GitHub. Fix the pin. Do not paper over a version skew by editing proofs.

Then open one theorem and `#print` the statement. Read it. Ask whether it is the informal claim you thought it was. That second step is statement match. The build only did level 1.

A one-line Cedar / AlphaProof pairing, of the kind you can put on a slide:

> Cedar ships a Lean spec and a Rust engine; AlphaProof's IMO 2024 silver was a Lean term the kernel accepted. In both cases the kernel is the referee, not the author.

The author can be a human, a tactic, or a model. The referee does not change.


## Write and judge in the same file

The thesis is not a slogan. Here is a file that is both a program and a judgement. The program decides whether a path is in a sandbox. The judgement is a theorem that every accepted read satisfies that decision. The types are small on purpose; Chapter 3 will replace the `Bool` with a real inductive.

```lean
def inSandbox (path : String) : Bool :=
  !path.isEmpty && !path.startsWith "/" && !path.contains ".."

inductive Action where
  | read  (path : String)
  | write (path : String) (contents : String)
  | done  (summary : String)
deriving Repr, BEq

def permitted : Action → Bool
  | .read path    => inSandbox path
  | .write path _ => inSandbox path
  | .done _       => true

def handle (a : Action) : Except String Action :=
  if permitted a then .ok a else .error "denied"

theorem handle_ok_means_permitted (a a' : Action)
    (h : handle a = .ok a') : permitted a' = true := by
  simp [handle] at h
  split at h
  · simp_all
  · contradiction
```

`handle` is executable. `#eval handle (.read "workspace/Main.lean")` returns `.ok ...`. `#eval handle (.read "/etc/passwd")` returns `.error "denied"`. The theorem is the judgement: if `handle` said yes, `permitted` was `true`. An agent that wants to take a step must inhabit `handle a = .ok a'` or, better, inhabit a structure that *includes* the proof:

```lean
structure Step where
  action : Action
  ok     : permitted action = true
```

A value of type `Step` is not a suggestion. It includes a proof that the action passed the policy. The runtime that executes `Step`s does not re-check the English policy. It pattern-matches on `action` and runs it. The kernel already checked `ok`.

You can do the Boolean part in Python. You cannot do the *dependent record* part in Python without building a checker. Lean is the checker, and also the language you write `Action` in.

A more honest `Step` later will not use `Bool` at all. It will use a `Prop`. The Boolean version is here because it is the first time most engineers see a field that is a proof. `ok` is not metadata. It is why the value exists.

Two failure cases you should type once.

First, delete `| done` from `permitted` and rebuild. Lean refuses: the match is not exhaustive. That is the kernel, through the elaborator, telling you the model of the world and the interpreter of the world have diverged.

Second, replace the theorem's proof with `sorry` and run `#print axioms handle_ok_means_permitted`. You will see `sorryAx`. The file still elaborates. The certificate is fake. Chapter 2's CI snippet is the product response: treat `sorry` as a failed build, not as a yellow warning you learn to ignore.

## What you are building toward

Three artifacts, named now so the early chapters have a destination.

**Agents that emit Lean.** The model writes definitions, theorems, and tactic scripts. The unit of emission is a file fragment or a REPL command, not a paragraph of intent. You grade the emission by whether Lake builds and whether the stated types are the types you asked for.

**Lean that verifies agent claims.** The model is allowed to say "this patch preserves the public API" only by submitting a theorem of that type. The kernel accepts or refuses. Refusals go back into the loop as goals and error messages. Acceptances become artifacts you can store next to the patch.

**Lean programs that are themselves agent tools.** A tool is a function. Its input type is the checked request. Its output type is the checked result. A tool that returns "12 rows" returns a `Vector` of length 12, or a `Σ n, Vector α n`, not a JSON array and a hope. The agent that consumes the tool result has to respect the type.

Part I does not ship the full loop. It ships the language the loop is written in. Chapter 2 is the kernel and the `Prop` / `Type` split. Chapter 3 is `ToolCall` / `ToolResult` / `Trace`. Chapter 4 is a `Capable` typeclass: a capability is an instance, not a boolean flag. Chapter 5 is the first executable agent loop in `do`, on the 4.32 elaborator.

If you take nothing else, take the referee picture. The model proposes. The elaborator translates. The kernel judges. You choose the type that counts as winning. Everything else in Lean — tactics, libraries, syntax sugar, Python bindings — is machinery for getting a term in front of that judge.
