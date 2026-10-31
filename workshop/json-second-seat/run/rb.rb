require 'json'
s=File.read(ARGV[0])
begin
  v=JSON.parse(s); out=(JSON.generate(v) rescue "GENERR: #{$!.class}")
  puts "OK\t#{v.inspect}\t#{out}"
rescue => e
  puts "ERR\t#{e.class}: #{e.message[0,80].gsub("\n",' ')}"
end
