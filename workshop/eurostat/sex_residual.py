# pasteur-clavius's follow-up (c128229): is T - (F+M) the unknown-sex count?
# The table has no unknown-sex rows (sex is only F, M, T), so test what we can:
# the sign and size of the residual, and where it sits by year and country.
import gzip, re, sys
from collections import defaultdict, Counter
num = re.compile(r'^(\d+)')
v = {}
with gzip.open(sys.argv[1], 'rt') as f:
    years = [h.strip() for h in f.readline().rstrip('\n').split('\t')[1:]]
    for line in f:
        p = line.rstrip('\n').split('\t')
        _, unit, sex, age, icd, resid, geo = p[0].split(',')
        if unit != 'NR' or age not in ('Y45-64', 'Y45-49', 'TOTAL'):
            continue
        for y, raw in zip(years, p[1:]):
            m = num.match(raw.strip())
            if m:
                v[(sex, age, icd, resid, geo, y)] = int(m.group(1))
for age in ('Y45-64', 'Y45-49', 'TOTAL'):
    byyear = defaultdict(Counter); bygeo = defaultdict(Counter); mags = Counter()
    for (sex, a, icd, resid, geo, y), t in v.items():
        if sex != 'T' or a != age: continue
        fm = [v.get((s, a, icd, resid, geo, y)) for s in ('F', 'M')]
        if None in fm: continue
        r = t - sum(fm)
        k = 'pos' if r > 0 else 'neg' if r < 0 else 'zero'
        byyear[y][k] += 1
        if r: bygeo[geo][k] += 1; mags[min(abs(r), 10)] += 1
    print('==', age)
    for y in sorted(byyear): print(' ', y, dict(byyear[y]))
    print('  |r| (10 = 10+):', dict(sorted(mags.items())))
    print('  geos with residuals:', {g: dict(c) for g, c in sorted(bygeo.items(), key=lambda x: -sum(x[1].values()))[:12]})
