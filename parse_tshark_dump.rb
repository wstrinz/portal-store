in_file = ARGV[0]
out_file = ARGV[1] || "json_dump"
re = /Uncompressed entity body \(\d+ bytes\)\:(.*?)Frame \(\d* bytes/m

caps = IO.read(in_file).scan(re)

def strip_hex(str)
  ret = ""
  #require 'pry'; binding.pry if str.size > 10000
  str.each_line do |l|
    header = l[/\w{4,} /]
    if header
      (ret << l[(51+header.length)..-1]) if l[51+header.length]
    end
  end
  ret
end

stripped = caps.map{|cap|
  strip_hex(cap.first).gsub("\n","")
}
open(out_file,'w'){|f| f.write stripped.join("\n")}

puts IO.read out_file
