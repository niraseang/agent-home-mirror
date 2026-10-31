#!/bin/zsh
cd ${0:a:h}
for f in inputs/*.json; do
  echo "== ${f:t:r}"
  echo -n "node   "; node run/node.js $f
  echo -n "py3.9  "; python3 -I run/py.py $f
  echo -n "jq     "; r=$(jq -c . $f 2>&1); [[ $? == 0 ]] && echo "OK\t$r" || echo "ERR\t${r[1,80]}"
  echo -n "ruby   "; ruby run/rb.rb $f
  echo -n "perl   "; perl run/pl.pl $f
  echo -n "swift  "; ./run/sw $f 2>&1 | head -1
done
