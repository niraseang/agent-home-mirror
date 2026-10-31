# For each cell, compare the Y45-64 residual T-(F+M) with the summed residuals
# of its four 5-year bands. If T for the aggregate were transmitted like the
# bands' T, the two should match; if derived as F+M, the aggregate shows 0.
import gzip, re, sys
from collections import Counter
num = re.compile(r'^(\d+)')
bands = ('Y45-49', 'Y50-54', 'Y55-59', 'Y60-64')
v = {}
with gzip.open(sys.argv[1], 'rt') as f:
    years = [h.strip() for h in f.readline().rstrip('\n').split('\t')[1:]]
    for line in f:
        p = line.rstrip('\n').split('\t')
        _, unit, sex, age, icd, resid, geo = p[0].split(',')
        if unit != 'NR' or age not in bands + ('Y45-64',): continue
        for y, raw in zip(years, p[1:]):
            m = num.match(raw.strip())
            if m: v[(sex, age, icd, resid, geo, y)] = int(m.group(1))
def r(a, k):
    t, f_, m_ = (v.get((s, a) + k) for s in 'TFM')
    return None if None in (t, f_, m_) else t - f_ - m_
out = {}
for (sex, a, icd, resid, geo, y) in list(v):
    if sex != 'T' or a != 'Y45-64': continue
    k = (icd, resid, geo, y)
    agg = r('Y45-64', k); bs = [r(b, k) for b in bands]
    if agg is None or None in bs: continue
    sb = sum(bs)
    if agg == 0 and sb == 0: continue
    out.setdefault(y, Counter())['agg=bandsum' if agg == sb else 'agg=0,bands>0' if agg == 0 else 'other'] += 1
for y in sorted(out): print(y, dict(out[y]))
# 2019 is mixed: which countries fall in which class?
g = {}
for (sex, a, icd, resid, geo, y) in list(v):
    if sex != 'T' or a != 'Y45-64' or y != '2019': continue
    k = (icd, resid, geo, y); agg = r('Y45-64', k); bs = [r(b, k) for b in bands]
    if agg is None or None in bs or (agg == 0 and sum(bs) == 0): continue
    c = 'eq' if agg == sum(bs) else 'zero' if agg == 0 else ('lt' if agg < sum(bs) else 'gt')
    g.setdefault(geo, Counter())[c] += 1
print('2019 by geo:', {k: dict(c) for k, c in sorted(g.items())})
