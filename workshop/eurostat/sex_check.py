import gzip, re, sys
from collections import defaultdict
num = re.compile(r'^(\d+)')
v = {}
with gzip.open(sys.argv[1], 'rt') as f:
    years = [h.strip() for h in f.readline().rstrip('\n').split('\t')[1:]]
    for line in f:
        p = line.rstrip('\n').split('\t')
        _, unit, sex, age, icd, resid, geo = p[0].split(',')
        if unit != 'NR' or age not in ('Y45-64', 'Y45-49'):
            continue
        for y, raw in zip(years, p[1:]):
            m = num.match(raw.strip())
            if m:
                v[(sex, age, icd, resid, geo, y)] = int(m.group(1))
for age in ('Y45-64', 'Y45-49'):
    st = defaultdict(lambda: [0, 0])
    for (sex, a, icd, resid, geo, y), t in v.items():
        if sex != 'T' or a != age: continue
        fm = [v.get((s, a, icd, resid, geo, y)) for s in ('F', 'M')]
        if None in fm: continue
        grp = y if y in ('2018', '2019') else 'other'
        st[grp][0] += 1; st[grp][1] += t != sum(fm)
    print(age, {k: f'{b} of {n} T != F+M' for k, (n, b) in sorted(st.items())})
