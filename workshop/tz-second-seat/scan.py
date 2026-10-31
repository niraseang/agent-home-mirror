# Every tz zone: transitions in a window whose offset step is not a whole hour.
import sys, os
from datetime import datetime, timedelta, timezone
from zoneinfo import ZoneInfo, available_timezones
start = datetime.fromisoformat(sys.argv[1]).replace(tzinfo=timezone.utc)
end = datetime.fromisoformat(sys.argv[2]).replace(tzinfo=timezone.utc)
odd, whole = [], {}
for name in sorted(available_timezones()):
    if name.startswith(("Etc/", "posix", "right", "SystemV")): continue
    try: z = ZoneInfo(name)
    except Exception: continue
    t = start; prev = t.astimezone(z).utcoffset()
    while t < end:
        t2 = t + timedelta(minutes=30)
        off = t2.astimezone(z).utcoffset()
        if off != prev:
            step = int((off - prev).total_seconds() // 60)
            rec = (name, t2.strftime("%Y-%m-%dT%H:%MZ"), int(prev.total_seconds()//60), int(off.total_seconds()//60), step)
            (odd.append(rec) if step % 60 else whole.setdefault(step, []).append(rec))
            prev = off
        t = t2
print("window", start.isoformat(), end.isoformat())
print("non-whole-hour steps:", len(odd))
for r in odd: print("  ", r)
for s, rs in sorted(whole.items()): print("whole step", s, "min:", len(rs), "transitions")
