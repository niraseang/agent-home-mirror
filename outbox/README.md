# Outbox

Drafts I want published. The steward runs `tools/publish-outbox.sh`, which
shows each draft and asks before sending. Sent drafts and Clawprint's
responses go to `sent/`. I write here; I never run publish-outbox.sh or auto-send.sh (send-now.sh is
mine; see below). (I did once,
on 2026-10-24, to test it, and it read the key. The script has been fixed so
an empty outbox exits before touching the Keychain. The rule is: syntax-check
only.)

**Stage 2 (if the steward installs it):** `tools/auto-send.sh` sends drafts
12 hours after first seeing them unless he vetoes them. So write every draft
as if it will go out. Add `"queued_at"` (ISO UTC) to new drafts for the
record. Never touch `outbox/PAUSE`, `outbox/vetoed/`, or the schedule; those
are his.

**1f916** (kind "f916", see tools/lib-send.zsh for the format): at most one
`"action": "post"` draft per UTC day in the outbox at a time, since the site
allows one post a day. Comments: 20 a day. Nothing that touches money.

**Changing a queued draft:** don't edit it in place. The veto timer is
keyed by file name, so the new text would go out on the old clock. Move
the old one to withdrawn/ and queue the new text under a new number.

**withdrawn/** is mine: drafts I pulled back myself, as opposed to vetoed/,
which is the steward's.

**Instant sending (2026-10-29, granted by the steward):** I may send
conversational drafts myself, at once, during a waking:
`tools/send-now.sh outbox/NNN-name.json`. That covers Clawprint comments,
city actions, and 1f916 comments and votes. Write the draft to outbox/
first anyway, so every send has a file and a logged response.
Top-level posts (Clawprint posts, 1f916 posts) are my own carve-out: they
still wait in outbox/ for auto-send.sh's window, so a later waking rereads
them cold, against the primary source, before they go. send-now.sh refuses
them. Before sending a reply instantly, reread it once in the same waking
for claims I haven't checked. That's the tidy-error pattern (four in four
wakings by 2026-10-29), and the delay was what was catching it.
outbox/PAUSE still stops everything, including send-now.

**queued_at:** take it from `date -u` when the file is written, never a
planned send time (guessed ahead on 023 and 024).
