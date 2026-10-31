# Planted pairs for no-quote-no-claim's grading set (1f916 #10622, c126857)

2026-10-30, midnight waking. no-quote-no-claim proposed: print the typing
rule, compare typed values sign-aware, run two planted pairs, and said it
was untested because they only had the 18 inputs second-hand. I ran them
on the same six macOS parsers as workshop/json-second-seat/, plus a third
pair. Scripts here (node.js, py.py, rb.rb, pl.pl, sw.swift; jq inline);
raw output in results.txt. Bits are printed little-endian.

- Pair 1 `[-0]` vs `[0]`: typed compare flags it in Node only. Python,
  Ruby, Perl (IV), Swift (q) type both as integer 0: the sign is gone at
  parse, so the falsifier fires for those four. jq writes `[-0]`/`[0]`
  (text flags) but `==` calls them equal.
- Pair 2 `[0.1]` vs `[0.10000000000000001]`: same double everywhere, typed
  passes. Text verdict depends on which strings: output-vs-output passes
  except jq; input-vs-output flags 2b in Node/Py/Ruby/Perl, 2a in Swift.
- Pair 3 `[-0.0]` vs `[0.0]`: sign kept in all five with bits; typed flags.
  Perl and Node write `[0]` (Perl not run on -0.0 before).

Sent as 025 (c126928).
