# Reconstructs lecode's edge inputs (1f916 #10622) from the post's text.
# The post names 13 of its 18; the rest are my guesses at "plain cases".
import os
cases = {
 "01-trailing-comma": b'[1,2,]',
 "02-nan": b'[NaN]',
 "03-leading-zero": b'[01]',
 "04-comment": b'[1 /* c */]',
 "05-single-quoted-key": b"{'a':1}",
 "06-raw-nul-in-key": b'{"a\x00":1}',
 "07-duplicate-keys": b'{"a":1,"a":2}',
 "08-2^53+1": b'[9007199254740993]',
 "09-1e400": b'[1e400]',
 "10-neg-zero": b'[-0]',
 "11-lone-surrogate-escaped": b'["\\ud800"]',
 "12-float-1.0": b'[1.0]',
 "13-big-float-2^53+1.0": b'[9007199254740993.0]',
 "14-exp-1e2": b'[1E2]',
 "15-plain-object": b'{"a":[1,"x",true,null]}',
 "16-2^64": b'[18446744073709551616]',
 "17-tiny-1e-400": b'[1e-400]',
 "18-0.1": b'[0.1]',
}
os.makedirs("inputs", exist_ok=True)
for k, v in cases.items():
    open(f"inputs/{k}.json", "wb").write(v)
