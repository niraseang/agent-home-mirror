#!/bin/zsh
# Veto window (stage 2 in letters/0020). The steward schedules this; the agent
# never runs it. Each run:
#   - notices new drafts in outbox/ and shows a macOS notification:
#     "Queued: ... Sends after <time> unless vetoed."
#   - sends drafts whose window (VETO_HOURS from when this script first saw
#     them) has passed, at most MAX_PER_RUN per run
#   - logs everything to outbox/auto-send.log and commits
#
# To veto one draft: move it to outbox/vetoed/ (or delete it).
# To stop everything: touch outbox/PAUSE   (remove the file to resume).
# To see what it would do without sending or reading keys:
#   DRY_RUN=1 tools/auto-send.sh
set -u
VETO_HOURS=${VETO_HOURS:-12}
ALLOWED_KINDS=(post comment city f916)   # stage 3 would narrow or widen this per place
MAX_PER_RUN=3

source ~/agent-home/tools/lib-send.zsh
cd "$HOME_DIR" || exit 1
setopt null_glob
mkdir -p outbox/.seen outbox/vetoed
LOG=outbox/auto-send.log
DRY=${DRY_RUN:-0}

now=$(date -u +%s)
log() { local line="$(date -u +%Y-%m-%dT%H:%M:%SZ) $*"; echo "$line"; (( DRY )) || print -r -- "$line" >> "$LOG"; }
notify() {
  (( DRY )) && { echo "[would notify] $1"; return; }
  osascript -e 'on run argv' -e 'display notification (item 1 of argv) with title "agent-home outbox"' -e 'end run' "$1" >/dev/null 2>&1
}

if [[ -e outbox/PAUSE ]]; then log "paused (outbox/PAUSE exists); nothing sent"; exit 0; fi

sent=0
for f in outbox/*.json; do
  base=$(basename "$f" .json)
  kind=$(draft_kind "$f" 2>/dev/null) || { log "skip $base: unreadable draft"; continue; }
  if (( ! ${ALLOWED_KINDS[(Ie)$kind]} )); then log "hold $base: kind '$kind' is not auto-sendable; use publish-outbox.sh"; continue; fi
  summary=$(draft_summary "$f")

  marker=outbox/.seen/$base
  if [[ ! -e $marker ]]; then
    due=$(( now + VETO_HOURS * 3600 ))
    if (( ! DRY )); then echo $now > "$marker"; fi
    notify "Queued: $summary. Sends after $(date -r $due '+%a %-I:%M %p') unless vetoed."
    log "queued $base ($summary); due $(date -u -r $due +%Y-%m-%dT%H:%M:%SZ)"
    continue
  fi

  first_seen=$(cat "$marker")
  due=$(( first_seen + VETO_HOURS * 3600 ))
  if (( now < due )); then continue; fi
  if (( sent >= MAX_PER_RUN )); then log "defer $base: per-run limit reached"; continue; fi

  if (( DRY )); then echo "[would send] $base ($summary)"; continue; fi
  if out=$(send_draft "$f"); then
    rm -f "$marker"; (( sent++ ))
    log "sent $base ($summary)"
    notify "Sent: $summary"
  else
    log "FAILED $base ($summary): $(print -r -- "$out" | head -c 300)"
    notify "Failed to send: $summary (left in outbox)"
  fi
done

# Clean up markers for drafts the steward vetoed or deleted.
for m in outbox/.seen/*; do [[ -e outbox/$(basename "$m").json ]] || rm -f "$m"; done

if (( ! DRY )); then
  git add -A outbox && git commit -qm "auto-send run: $sent sent" >/dev/null 2>&1
fi
exit 0
