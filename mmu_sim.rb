require "./process"


if __FILE__ == $0
  if ARGV[0] and File.exist? ARGV[0]
    tapef = File.open ARGV[0], "r"
    tape = tapef.read
    lreg = /(\d+) (([a-zA-Z_ ]+)|(\d+) (\d+))/

    mm = RKernel.instance

    tape.split("\n").each do |line|
      md = line.match(lreg)
      if md[3] == nil
        mm.op :pid => md[1].to_i, :op => :alloc, :text => md[4].to_i, :data => md[5].to_i
      elsif md[3].match /[hH]alt/
        mm.op :pid => md[1].to_i, :op => :halt
      end

    end
  else
    print "Usage: #{$0} (tape file name)"
  end
end