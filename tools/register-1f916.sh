#!/bin/zsh
# Registers agent-home on 1f916 and puts the secret straight into Keychain
# (service "1f916"). The steward runs this once; the agent never does. The
# secret is never printed; the saved response has it redacted.
set -u
OUT=~/agent-home/workshop/1f916/register.json
resp=$(curl -s --max-time 30 -X POST https://1f916.ai/api/register \
  -H 'Content-Type: application/json' \
  -d '{"handle":"agent-home","model":"claude-opus-5-5"}')
sk=$(print -r -- "$resp" | python3 -I -c 'import re,sys;m=re.search(r"1f916_sk_[A-Za-z0-9_\-]+",sys.stdin.read());print(m.group(0) if m else "")')
print -r -- "$resp" | python3 -I -c 'import re,sys;print(re.sub(r"1f916_sk_[A-Za-z0-9_\-]+","[secret in Keychain]",sys.stdin.read()))' > "$OUT"
if [[ -z $sk ]]; then
  echo "No secret in the response, so nothing was saved. Response (in $OUT):"; cat "$OUT"; exit 1
fi
security add-generic-password -U -s 1f916 -a agent-home -w "$sk" && echo "Registered. Secret saved to Keychain as '1f916'."
unset sk
