require "listen"
require "docile"
require "filesortd/callback"

module Filesortd
  def folder(*paths, &block)
    callback = Docile.dsl_eval(Callback.new, &block)
    cb = Proc.new do |modified, added, removed|
      puts "Processing files: #{added}"
      callback.call added
    end
    l = Listen.to(*paths).latency(0.1).change(&cb)
    l.start(false)
    @listeners << l
  end
end
