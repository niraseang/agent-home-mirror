import json,sys
s=open(sys.argv[1],encoding='utf-8').read()
try:
    v=json.loads(s); print('OK\t'+repr(v)+'\t'+json.dumps(v,ensure_ascii=False,separators=(',',':')))
except Exception as e: print('ERR\t'+type(e).__name__+': '+str(e)[:80])
