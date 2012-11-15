require "./lib/kernel"
require "sinatra"
require "erb"


if __FILE__ == $0
  if ARGV[0] and File.exist? ARGV[0]
    tapef = File.open ARGV[0], "r"
    tape = tapef.read
    RKernel.instance.feed tape
  else
    print "Usage: #{$0} (tape file name)"
    exit
  end
end


get "/" do
  erb :index
end

get "/step" do
  RKernel.instance.step
  redirect "/"
end

get "/reset" do
  RKernel.instance.reset
  RKernel.instance.feed tape
  redirect "/"
end