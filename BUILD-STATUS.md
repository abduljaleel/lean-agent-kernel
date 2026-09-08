# book-code build status

**When:** 2026-09-09 ~06:05 AEST (Melbourne) — weekday income session  
**Toolchain:** `leanprover/lean4:v4.32.0` (commit `8c9756b28d64`, Release)  
**Package:** GitHub `abduljaleel/lean-agent-kernel` (`scripts/ci.sh`)

## Commands

```
bash ./scripts/ci.sh
```

## Results

| Check | Result |
|---|---|
| `lake build` | **green** — `Build completed successfully (26 jobs).` |
| sorry-grep | **ok** |
| axiom audit | **ok** — `Ch18.selfTest_ok` depends on `propext`, `Classical.choice`, `Quot.sound` (no `native_decide` / `sorryAx` on this run) |
| `lake exe checker -- --self-test` | **exit 0** — prints `self-test ok` |
| Mathlib | not used |

GitHub Actions for this script is blocked until a token with `workflow` scope can write `.github/workflows/`.

Prior green rechecks: 2026-08-16, 2026-08-31, 2026-09-02, 2026-09-03.

---

**When:** 2026-09-03 ~09:25 AEST (Melbourne) — weekday income session  
**Toolchain:** `leanprover/lean4:v4.32.0` (commit `8c9756b28d64`, Release)  
**Package:** GitHub `abduljaleel/lean-agent-kernel` (`scripts/ci.sh`)

## Commands

```
bash ./scripts/ci.sh
```

## Results

| Check | Result |
|---|---|
| `lake build` | **green** — `Build completed successfully (26 jobs).` |
| sorry-grep | **ok** |
| axiom audit | **ok** — `Ch18.selfTest_ok` depends on `propext`, `Classical.choice`, `Quot.sound` (no `native_decide` / `sorryAx` on this run) |
| `lake exe checker -- --self-test` | **exit 0** — prints `self-test ok` |
| Mathlib | not used |

GitHub Actions for this script is blocked until a token with `workflow` scope can write `.github/workflows/`.

Prior green rechecks: 2026-08-16, 2026-08-31, 2026-09-02.

---


**When:** 2026-09-02 ~09:10 AEST (Melbourne) — weekday income session recheck  
**Toolchain:** `leanprover/lean4:v4.32.0` (commit `8c9756b28d64`, Release)  
**Package:** `/workspace/lean-agent-kernel-public` (same tree as GitHub `abduljaleel/lean-agent-kernel`)

## Commands

```
cd /workspace/lean-agent-kernel-public
lake build
lake exe checker -- --self-test
```

## Results

| Check | Result |
|---|---|
| `lake build` | **green** — `Build completed successfully (26 jobs).` |
| `lake exe checker -- --self-test` | **exit 0** — prints `self-test ok` |
| `sorry` in `*.lean` | **zero** |
| Mathlib | not used |

Prior green rechecks: 2026-08-16, 2026-08-31. Paid PDFs remain out of the public tarball. Gumroad `urepwg` still unpublished.

---

## Historical — first full verify (2026-08-16)


**When:** 2026-08-16 14:12 AEST (Melbourne)  
**Toolchain:** `leanprover/lean4:v4.32.0` (commit `8c9756b28d64`, Release)  
**Package:** `/workspace/book-revision/book-code`

## Commands

```
cd /workspace/book-revision/book-code
lake build
lake exe checker -- --self-test
```

## Results

| Check | Result |
|---|---|
| `lake build` | **green** — `Build completed successfully (26 jobs).` |
| `lake exe checker -- --self-test` | **exit 0** — prints `self-test ok` |
| `sorry` in `*.lean` | **zero** (`rg sorry --glob '*.lean'` is empty) |
| Mathlib | not used |
| `| while` constructor | kept; parses on 4.32.0 |

`lakefile.toml` `defaultTargets` was `["book-code", "checker"]`. Lake 4.32 reports `package 'book-code' has no target 'book-code'` because the lib target is `BookCode`. Changed to `["BookCode", "checker"]`.

## First full `lake build` log (abridged)

```
info: book-code: no previous manifest, creating one from scratch
info: toolchain not updated; already up-to-date
ℹ [2/26] Built BookCode.Ch02 (533ms)
info: BookCode/Ch02.lean:15:0: 6
info: BookCode/Ch02.lean:31:0: Fin 5 : Type
✔ [3/26] Built BookCode.Json (680ms)
✔ [4/26] Built BookCode.Ch10 (399ms)
✔ [5/26] Built BookCode.Types (466ms)
ℹ [8/26] Built BookCode.Ch03 (511ms)
info: BookCode/Ch03.lean:35:0: "list_dir"
info: BookCode/Ch03.lean:36:0: 1
info: BookCode/Ch03.lean:37:0: false
info: BookCode/Ch03.lean:38:0: "read src/Main.lean"
ℹ [9/26] Built BookCode.Ch04 (514ms)
info: BookCode/Ch04.lean:27:0: Except.ok { name := "read", ... }
info: BookCode/Ch04.lean:28:0: Except.error "denied by tool"
✔ [10/26] Built BookCode.Ch05
✔ [11/26] Built BookCode.Ch06
✔ [12/26] Built BookCode.Axioms
✔ [14/26] Built BookCode.SidebarFalse
✔ [15/26] Built BookCode.Ch16
✔ [17/26] Built BookCode.Ch17
✔ [18/26] Built BookCode.Ch18
✔ [20/26] Built Main
✔ [21/26] Built BookCode.Audit
✔ [24/26] Built BookCode
✔ [26/26] Built checker:exe
Build completed successfully (26 jobs).
```

`#eval twice (3 : Int)` prints `6`. There is no `#eval twice "na"`.

## Verbatim compiler errors captured for comment blocks

Throwaway files compiled with `lean` 4.32.0 on this machine.

### `#synth Add String`

```
failed to synthesize
  Add String

Hint: Additional diagnostic information may be available using the `set_option diagnostics true` command.
```

`#synth Append String` succeeds (`instAppendString`). Quoted in `BookCode/Ch02.lean`.

### `example (n : Nat) : 0 + n = n := by rfl`

```
Tactic `rfl` failed: The left-hand side
  0 + n
is not definitionally equal to the right-hand side
  n

n : Nat
⊢ 0 + n = n
```

Quoted in `BookCode/Ch02.lean`. The swapped identity `n + 0 = n := rfl` succeeds (definitional; `Nat.add` recurses on the second argument).

## Defects closed (see `/workspace/book-revision/DEFECTS.md`)

1. **`n+0` / `0+n`.** `add_zero` is `rfl`. `zero_add` is induction + `congrArg Nat.succ`. Ch02 comments quote the real `0 + n` `rfl` failure, not the book's inverted story.
2. **`Add String`.** `[Add α]` kept; only `#eval twice (3 : Int)`. String concat is `Append` / `++`.
3. **`| while`.** Kept. Live 4.32.0 probe: constructor parses (lean exit 0). DEFECTS.md's "parse error" claim is wrong for this toolchain.
4. **`checkNodePre` / `checkNodePost`** defined before `replayStep`.
5. **`parseJson`** defined, total (`null`/`true`/`false`/quoted string/else `.str s`).
6. **`hash : String → UInt64`** (fold `* 31 + char`), not compared to a `String`.
7. **`checkReadFilePre_sound`** closed (`simp` / `cases` / `eq_of_beq`). Re-exported from Ch18 with no second hole.
8. **`drainQuota`** compiles. Hoare triple is comment `EXERCISE 17.4` with invariant `s.counter ≤ quota ∧ acc.length ≤ calls.length`.
9. **Axioms are not free-`Prop`.** `interp` / `interpRun` are fixed functions of the recorded data. `SidebarFalse.lean` has no axioms; it shows the *naive* types prove `False`.

## `#print axioms` (via `lake env lean`)

| Theorem | Axioms |
|---|---|
| `Ch02.add_zero` | none |
| `Ch02.zero_add` | none |
| `Ch16.checkReadFilePre_sound` | `propext`, `Classical.choice`, `Quot.sound` |
| `Ch16.mint` | `propext`, `BookCode.tableAttest` |
| `Ch18.selfTest_ok` | `propext`, `Classical.choice`, `Quot.sound`, plus `native_decide` |

No `sorryAx`.

## Modules

`Json`, `Types`, `Ch02`, `Ch03`, `Ch04`, `Ch05`, `Ch06`, `Ch10`, `Axioms`, `SidebarFalse`, `Ch16`, `Ch17`, `Ch18`, `Audit`, root `BookCode.lean`, exe `Main.lean` (`checker`).
