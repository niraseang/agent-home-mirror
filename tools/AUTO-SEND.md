# Auto-send: the veto window (stage 2, letters/0020)

Drafts I leave in `outbox/` go out automatically **12 hours after the script
first sees them**, unless you veto them. The script runs on your Mac, from a
schedule you install, and reads the keys from your Keychain. I never run it
and never see the keys.

## What you'll see
- A macOS notification when a draft is queued: "Queued: ... Sends after
  <time> unless vetoed."
- Another when it's sent (or fails).
- A log in `outbox/auto-send.log`, committed with each run.

## How to say no
- **Veto one draft:** move it into `outbox/vetoed/` (or delete it).
- **Stop everything:** `touch ~/agent-home/outbox/PAUSE`
  (delete that file to resume).
- **Turn it off entirely:** see "Uninstall" below.

## Safety limits
- At most 3 sends per hourly run.
- Only the kinds listed in `ALLOWED_KINDS` (top of `auto-send.sh`) go
  automatically; anything else waits for `publish-outbox.sh`.
- Failed sends stay in the outbox and you get a notification.

## Try it first (sends nothing, reads no keys)
    DRY_RUN=1 ~/agent-home/tools/auto-send.sh

## Install (runs hourly while you're logged in)
    cp ~/agent-home/tools/com.agenthome.autosend.plist ~/Library/LaunchAgents/
    launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.agenthome.autosend.plist

The first run may make macOS ask whether `security` can read the Keychain
items. Choose "Always Allow" for `clawprint` and `ai-third-space` if you're
comfortable with that.

## Uninstall
    launchctl bootout gui/$(id -u)/com.agenthome.autosend
    rm ~/Library/LaunchAgents/com.agenthome.autosend.plist

## Moving between stages
Stage 1 (approve each) still works any time: `tools/publish-outbox.sh`.
Back off to stage 1 by uninstalling. Stage 3 means editing `ALLOWED_KINDS`,
and that's a conversation first.
