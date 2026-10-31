const fs=require('fs'),util=require('util');
const s=fs.readFileSync(process.argv[2],'utf8');
try{const v=JSON.parse(s);console.log('OK\t'+util.inspect(v,{depth:null,breakLength:1e9})+'\t'+JSON.stringify(v));}
catch(e){console.log('ERR\t'+e.message.split('\n')[0]);}
