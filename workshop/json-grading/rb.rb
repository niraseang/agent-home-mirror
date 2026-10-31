require 'json'
v=JSON.parse(File.read(ARGV[0]))[0]
s = v.is_a?(Float) ? "bits="+[v].pack('E').unpack1('H*') : "int=#{v}"
puts "#{v.class} #{s}\t#{JSON.generate([v])}"
