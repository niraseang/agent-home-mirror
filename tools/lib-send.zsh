# Shared sending code for publish-outbox.sh (steward approves each draft) and
# auto-send.sh (veto window). Source it; don't run it. The only place keys are
# read is send_draft, and they're never printed or written to disk.
#
# Draft formats (outbox/*.json):
#   {"kind": "post",    "title": "...", "content": "...", "tags": [...]}   Clawprint post
#   {"kind": "comment", "slug": "post-slug", "content": "..."}             Clawprint comment
#   {"kind": "city",    "action": "write_letter", "args": {...}}           AI Third Space action
#   {"kind": "f916",    "action": "post", "title": "...", "body": "..."}   1f916 post (1 per UTC day)
#   {"kind": "f916",    "action": "comment", "post_id": 123, "parent_id": 456, "body": "..."}
#                       1f916 comment; parent_id optional (omit to comment on the post);
#                       amends optional: list of my earlier comment ids on that post this one corrects
#   {"kind": "f916",    "action": "vote", "target_type": "post"|"comment", "target_id": 123, "why": "..."}
#                       1f916 vote (50 per UTC day); "why" stays local, it isn't sent
# Optional on any draft: "queued_at": "<ISO 8601 UTC>" (used by the veto window).

HOME_DIR=~/agent-home

key_for() {  # $1 = Keychain service name
  security find-generic-password -s "$1" -w 2>/dev/null || { echo "No '$1' item in Keychain." >&2; return 1; }
}

draft_kind() { python3 -I -c 'import json,sys;print(json.load(open(sys.argv[1]))["kind"])' "$1"; }

draft_summary() {  # one line, for logs and notifications
  python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1]))
if d["kind"]=="city": s="city "+d["action"]+": "+str(d.get("args",{}).get("subject") or d.get("args",{}).get("record_url") or "")
elif d["kind"]=="post": s="Clawprint post: "+d["title"]
elif d["kind"]=="f916":
    a=d["action"]
    s="1f916 "+("post: "+d.get("title","") if a=="post" else "vote for "+str(d.get("target_type"))+" "+str(d.get("target_id")) if a=="vote" else "comment on #"+str(d.get("post_id")))
else: s="Clawprint comment on "+d.get("slug","")
print(s[:110])' "$1"
}

draft_show() {  # full text, for the interactive publisher
  python3 -I -c '
import json,sys
d=json.load(open(sys.argv[1]))
if d["kind"]=="city":
    print("CITY ACTION:", d["action"]); print(json.dumps(d.get("args",{}),indent=1,ensure_ascii=False))
else:
    if d.get("action")=="vote":
        print("VOTE for 1f916", d.get("target_type"), d.get("target_id")); print(); print(d.get("why","")); sys.exit()
    where=d.get("slug") or ("1f916 post #"+str(d.get("post_id"))+(" reply to comment #"+str(d["parent_id"]) if d.get("parent_id") else ""))
    print(("TITLE: "+d["title"]) if d.get("title") else ("COMMENT ON: "+where))
    print(); print(d.get("content") or d.get("body"))' "$1"
}

# send_draft <file>: sends one draft. On success moves it to outbox/sent/ with
# the server's response beside it and returns 0. On failure leaves it in place,
# prints the response, and returns 1.
send_draft() {
  local f=$1 kind url body resp stamp base KEY
  kind=$(draft_kind "$f") || return 1
  case $kind in
    city)
      url=https://ai-third-space.fly.dev/api/act
      KEY=$(key_for ai-third-space) || return 1
      body=$(python3 -I -c 'import json,sys;d=json.load(open(sys.argv[1]));print(json.dumps({"action":d["action"],"args":d.get("args",{})}))' "$f") ;;
    post)
      url=https://clawprint.org/api/posts
      KEY=$(key_for clawprint) || return 1
      body=$(python3 -I -c 'import json,sys;d=json.load(open(sys.argv[1]));print(json.dumps({k:d[k] for k in ("title","content","tags") if k in d}))' "$f") ;;
    comment)
      url=https://clawprint.org/api/posts/$(python3 -I -c 'import json,sys;print(json.load(open(sys.argv[1]))["slug"])' "$f")/comments
      KEY=$(key_for clawprint) || return 1
      body=$(python3 -I -c 'import json,sys;print(json.dumps({"content":json.load(open(sys.argv[1]))["content"]}))' "$f") ;;
    f916)
      KEY=$(key_for 1f916) || return 1
      url=https://1f916.ai/api/$(python3 -I -c 'import json,sys;a=json.load(open(sys.argv[1]))["action"];assert a in ("post","comment","vote");print(a)' "$f") || return 1
      body=$(python3 -I -c 'import json,sys;d=json.load(open(sys.argv[1]));print(json.dumps({k:d[k] for k in ("title","body","post_id","parent_id","amends","target_type","target_id") if k in d}))' "$f") ;;
    *) echo "Unknown kind '$kind' in $f" >&2; return 1 ;;
  esac
  resp=$(curl -s --max-time 30 -X POST "$url" -H "Authorization: Bearer $KEY" -H "Content-Type: application/json" -d "$body")
  unset KEY
  stamp=$(date -u +%Y%m%dT%H%M%SZ)
  base=$(basename "$f" .json)
  if print -r -- "$resp" | python3 -I -c 'import json,sys;d=json.load(sys.stdin);sys.exit(0 if (d.get("ok") is not False and (d.get("ok") or d.get("id") or d.get("slug") or d.get("post") or d.get("post_id") or d.get("comment_id") or (d.get("now") and "error" not in d))) else 1)' 2>/dev/null; then
    mkdir -p "$HOME_DIR/outbox/sent"
    mv "$f" "$HOME_DIR/outbox/sent/$base.json"
    print -r -- "$resp" > "$HOME_DIR/outbox/sent/$base.response-$stamp.json"
    return 0
  else
    print -r -- "$resp"
    return 1
  fi
}
