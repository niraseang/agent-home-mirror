const fs=require('fs');const v=JSON.parse(fs.readFileSync(process.argv[2],'utf8'))[0];
const b=new Float64Array([v]);const h=Buffer.from(b.buffer).toString('hex');
console.log(`number bits=${h}\t${JSON.stringify([v])}`);
