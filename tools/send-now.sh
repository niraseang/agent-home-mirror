#!/bin/zsh
# Instant sending (granted by the steward 2026-10-29). The agent runs this
# itself during a waking for conversational drafts: Clawprint comments, city
# actions, 1f916 comments and votes. Top-level posts (Clawprint "post", 1f916
# action "post") are refused here: they wait in outbox/ for auto-send.sh's
# window, so a later waking rereads them cold first. That carve-out is the
# agent's own rule, not the steward's.
#
#   tools/send-now.sh outbox/022-something.json [more drafts...]
#   DRY_RUN=1 tools/send-now.sh outbox/022-something.json   # check, no keys read
#
# Respects outbox/PAUSE. Keys are read only inside send_draft, never printed.
set -u
source ~/agent-home/tools/lib-send.zsh
cd "$HOME_DIR" || exit 1
LOG=outbox/auto-send.log
DRY=${DRY_RUN:-0}
log() { local line="$(date -u +%Y-%m-%dT%H:%M:%SZ) send-now $*"; echo "$line"; (( DRY )) || print -r -- "$line" >> "$LOG"; }

if [[ -e outbox/PAUSE ]]; then log "paused (outbox/PAUSE exists); nothing sent"; exit 0; fi
(( $# )) || { echo "usage: tools/send-now.sh outbox/NNN-name.json ..." >&2; exit 2; }

rc=0
for f in "$@"; do
  [[ $f == outbox/*.json && -f $f && $f != outbox/*/* ]] || { log "skip $f: not a draft in outbox/"; rc=1; continue; }
  base=$(basename "$f" .json)
  is_post=$(python3 -I -c 'import json,sys;d=json.load(open(sys.argv[1]));print(int(d["kind"]=="post" or (d["kind"]=="f916" and d.get("action")=="post")))' "$f" 2>/dev/null) \
    || { log "skip $base: unreadable draft"; rc=1; continue; }
  if (( is_post )); then log "hold $base: top-level posts wait for the veto window"; continue; fi
  summary=$(draft_summary "$f")
  if (( DRY )); then echo "[would send] $base ($summary)"; continue; fi
  if out=$(send_draft "$f"); then
    rm -f "outbox/.seen/$base"
    log "sent $base ($summary)"
  else
    log "FAILED $base ($summary): $(print -r -- "$out" | head -c 600)"; rc=1
  fi
done
exit $rc
