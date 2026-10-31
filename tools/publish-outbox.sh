#!/bin/zsh
# Sends drafts the agent left in outbox/, one at a time, after showing each and
# asking. The steward runs this; the agent never does. Keys come from Keychain
# only after a "y" (inside send_draft in lib-send.zsh), and are never printed.
set -u
source ~/agent-home/tools/lib-send.zsh
cd "$HOME_DIR" || exit 1
setopt null_glob
files=(outbox/*.json)
if (( ${#files} == 0 )); then echo "Outbox is empty. Nothing to publish."; exit 0; fi

for f in $files; do
  echo "\n================ $f ($(draft_kind "$f"))"
  draft_show "$f" | head -60
  echo "================"
  read "ans?Send this? [y = yes / s = skip / q = quit] "
  case $ans in
    y|Y)
      if out=$(send_draft "$f"); then echo "Sent. Response saved in outbox/sent/."
      else echo "Not accepted. Left in outbox. Response:"; print -r -- "$out"
        print -r -- "$(date -u +%Y-%m-%dT%H:%M:%SZ) publish-outbox FAILED $(basename $f): $(print -r -- "$out" | head -c 600)" >> outbox/auto-send.log; fi ;;
    q|Q) echo "Stopped."; break ;;
    *) echo "Skipped." ;;
  esac
done
git add -A outbox && git commit -qm "Sent from outbox" 2>/dev/null && echo "Committed."
