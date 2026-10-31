import gzip, re, sys
from collections import defaultdict

path = sys.argv[1]
num = re.compile(r'^(\d+)')
AGG = {'Y45-64': ['Y45-49', 'Y50-54', 'Y55-59', 'Y60-64'],
       'Y30-44': ['Y30-34', 'Y35-39', 'Y40-44']}
need = set(AGG) | {b for v in AGG.values() for b in v}

# cells[(sex,icd,resid,geo,year)][age] = int
cells = defaultdict(dict)
flagged_zero = 0
with gzip.open(path, 'rt') as f:
    hdr = f.readline().rstrip('\n').split('\t')
    years = [h.strip() for h in hdr[1:]]
    for line in f:
        parts = line.rstrip('\n').split('\t')
        freq, unit, sex, age, icd, resid, geo = parts[0].split(',')
        if unit != 'NR' or age not in need:
            continue
        for y, raw in zip(years, parts[1:]):
            m = num.match(raw.strip())
            if not m:
                continue  # ':' and anything non-numeric is missing, never zero
            cells[(sex, icd, resid, geo, y)][age] = int(m.group(1))

for agg, bands in AGG.items():
    per_year = defaultdict(lambda: [0, 0])
    for k, ages in cells.items():
        if agg in ages and all(b in ages for b in bands):
            s = sum(ages[b] for b in bands)
            per_year[k[4]][0] += 1
            per_year[k[4]][1] += ages[agg] != s
    print(agg)
    other = [0, 0]
    for y in sorted(per_year):
        n, bad = per_year[y]
        if y in ('2018', '2019'):
            print(f'  {y}: {bad} of {n} differ')
        else:
            other[0] += n; other[1] += bad
    print(f'  other years: {other[1]} of {other[0]} differ')
    # direction check: any aggregate above its band sum?
    above = sum(1 for k, a in cells.items() if agg in a and all(b in a for b in bands)
                and a[agg] > sum(a[b] for b in bands))
    print(f'  cells where aggregate > band sum (any year): {above}')

print('EU27_2020, Y45-64, all causes (A-R_V-Y), T sex:')
for y in ('2017', '2018', '2019', '2020'):
    row = []
    for r in ('TOT_IN', 'TOT_RESID'):
        a = cells.get(('T', sys.argv[2], r, 'EU27_2020', y), {})
        row.append((sum(a.get(b, 0) for b in AGG['Y45-64']), a.get('Y45-64')))
    print(' ', y, row)
for g in ('DE', 'FR', 'IT', 'RO'):
    for y in ('2018', '2019'):
        out = []
        for r in ('TOT_IN', 'TOT_RESID'):
            a = cells.get(('T', sys.argv[2], r, g, y), {})
            out.append((r, sum(a.get(b, 0) for b in AGG['Y45-64']), a.get('Y45-64')))
        print(' ', g, y, out)
