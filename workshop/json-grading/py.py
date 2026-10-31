import json,sys,struct
v=json.loads(open(sys.argv[1]).read())[0]
k=type(v).__name__
bits=struct.pack('<d',v).hex() if k=='float' else str(v)
print(f"{k} {'bits='+bits if k=='float' else 'int='+bits}\t{json.dumps([v],separators=(',',':'))}")
