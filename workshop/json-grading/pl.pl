use JSON::PP; use B;
local $/; open my $f,'<',$ARGV[0]; my $t=<$f>;
my $v=JSON::PP->new->decode($t)->[0];
my $fl=B::svref_2object(\$v)->FLAGS;
my $k = ($fl & B::SVf_NOK) ? 'NV' : (($fl & B::SVf_IOK) ? 'IV' : 'PV');
my $s = $k eq 'NV' ? 'bits='.unpack('H*',pack('d<',$v)) : ($k eq 'IV' ? "int=$v" : "str=$v");
print "$k $s\t".JSON::PP->new->encode([$v])."\n";
