#!/usr/bin/env bash
# ten-proofs shape: pin → build → sorry-grep → axiom audit → self-test
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CODE="$ROOT"
export PATH="${HOME}/.elan/bin:${PATH}"

pin="$(tr -d ' \n' < "$CODE/lean-toolchain")"
if [[ "$pin" != "leanprover/lean4:v4.32.0" ]]; then
  echo "ci: lean-toolchain is '$pin', expected leanprover/lean4:v4.32.0" >&2
  exit 1
fi

cd "$CODE"

echo "== lake build =="
lake build

echo "== sorry-grep =="
if command -v rg >/dev/null 2>&1; then
  if rg -n --glob '*.lean' -e '^\s*sorry\b' -e '\bby sorry\b' -e '\bsorry\s*$' BookCode Main.lean; then
    echo "ci: sorry found in Lean sources" >&2
    exit 1
  fi
else
  if grep -R -n -E '^[[:space:]]*sorry\b|\bby sorry\b|\bsorry[[:space:]]*$' --include='*.lean' BookCode Main.lean; then
    echo "ci: sorry found in Lean sources" >&2
    exit 1
  fi
fi
echo "sorry-grep ok"

echo "== axiom audit =="
allowed='propext|Quot\.sound|Classical\.choice|tableAttest|llmExecAttest'
audit_out="$(mktemp)"
if ! lake env lean BookCode/PrintAxioms.lean >"$audit_out" 2>&1; then
  echo "ci: axiom audit file failed to elaborate" >&2
  cat "$audit_out" >&2
  exit 1
fi
if command -v rg >/dev/null 2>&1; then
  if rg -q "sorryAx|_native|native_decide" "$audit_out"; then
    echo "ci: sorryAx or native_decide in axiom list" >&2
    cat "$audit_out" >&2
    exit 1
  fi
  unexpected="$(rg -o "depends on axioms:.*" "$audit_out" | rg -o '[A-Za-z0-9_\.]+' | rg -v "depends|on|axioms" | rg -v -e "$allowed" || true)"
else
  if grep -E "sorryAx|_native|native_decide" "$audit_out"; then
    echo "ci: sorryAx or native_decide in axiom list" >&2
    cat "$audit_out" >&2
    exit 1
  fi
  unexpected=""
fi
if [[ -n "${unexpected}" ]]; then
  echo "ci: unexpected axioms:" >&2
  echo "$unexpected" >&2
  cat "$audit_out" >&2
  exit 1
fi
echo "axiom audit ok"
cat "$audit_out"

echo "== self-test =="
lake exe checker -- --self-test

echo "ci: green"
