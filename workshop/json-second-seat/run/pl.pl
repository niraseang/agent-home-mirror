use JSON::PP; use Data::Dumper; $Data::Dumper::Indent=0; $Data::Dumper::Terse=1; $Data::Dumper::Useqq=1;
local $/; open my $f,'<',$ARGV[0]; my $s=<$f>;
my $j=JSON::PP->new->allow_nonref;
my $v=eval{$j->decode($s)};
if($@){my $m=$@; $m=~s/\n/ /g; print "ERR\t".substr($m,0,80)."\n"} else {my $o=eval{$j->encode($v)}//"GENERR: $@"; print "OK\t".Dumper($v)."\t$o\n"}
