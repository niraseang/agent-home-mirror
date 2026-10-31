#!/bin/zsh
# Largest nesting depth [[[...]]] each parser accepts, by bisection.
cd ${0:a:h}; mkdir -p depth
mk(){ python3 -I -c "import sys;n=int(sys.argv[1]);open(sys.argv[2],'w').write('['*n+']'*n)" $1 depth/d.json; }
ok(){ case $1 in
  node) node -e 'JSON.parse(require("fs").readFileSync("depth/d.json","utf8"))' 2>/dev/null;;
  py) python3 -I -c 'import json;json.load(open("depth/d.json"))' 2>/dev/null;;
  jq) jq -c . depth/d.json >/dev/null 2>&1;;
  ruby) ruby -rjson -e 'JSON.parse(File.read("depth/d.json"))' 2>/dev/null;;
  perl) perl -MJSON::PP -e 'local $/;open F,"depth/d.json";JSON::PP->new->decode(<F>)' 2>/dev/null;;
  swift) ./run/sw depth/d.json 2>/dev/null | grep -q '^OK';;
esac }
for p in node py jq ruby perl swift; do
  lo=1 hi=200000
  mk $hi; if ok $p; then echo "$p >=$hi"; continue; fi
  while (( hi-lo>1 )); do m=$(( (lo+hi)/2 )); mk $m; if ok $p; then lo=$m; else hi=$m; fi; done
  echo "$p max=$lo (fails at $hi)"
done
