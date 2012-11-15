require "singleton"
require_relative "./process"
require_relative "./memory"

class RKernel
  include Singleton
  OPS = [:alloc, :halt, :write, :read]

  PHYSICAL_SIZE = 4096
  PAGE_SIZE = 512
  FRAMES = PHYSICAL_SIZE / PAGE_SIZE
  SWAP_SIZE = 40960
  SWAP_PAGES = SWAP_SIZE / PAGE_SIZE
  TLB_SIZE = 4

  attr_reader :mem, :swap, :process_list, :tlb, :ops

  def initialize
    @mem = Memory.new(PHYSICAL_SIZE, PAGE_SIZE)
    @swap = SwapMemory.new(SWAP_SIZE, PAGE_SIZE)
    @tlb = TLB.new(TLB_SIZE)
    @process_list = {}
    @ops = []
  end

  def reset
    initialize
  end

  def feed(tape)
    tokr = /(\d+)\s+(\w+)\s+([^#]+)/
    tape.split("\n").each do |line|
      md = line.match(tokr)
      pid = md[1].to_i
      op = md[2]
      args = md[3]


      if op.match /[aA]lloc/
        a = args.split(" ").map { |i| i.to_i }
        load :pid => pid, :op => :alloc, :text => a[0], :data => a[1]
      elsif op.match /[hH]alt/
        load :pid => pid, :op => :halt
      elsif op.match /[Rr]ead/
        a = args.match(/([a-z])(\d+)\s+(\d+)/)
        if a[1] == 'd'
          seg = :data
        elsif a[1] == 't'
          seg = :text
        end
        off = a[2].to_i
        size = a[3].to_i
        load :pid => pid, :op => :read, :segment=> seg,:offset => off, :size => size
      end
    end
  end

  def load(op)
    @ops.unshift(op)
  end

  def step
    op @ops.pop unless @ops.empty?
  end

  def op(args)
    case (args[:op])
      when :alloc
        @process_list[args[:pid]] = RProcess.new args[:pid], args[:text], args[:data]
      when :halt
        kill args[:pid]
      when :read
        @process_list[args[:pid]].read args[:segment], args[:offset], args[:size]
    end
  end

  def kill(pid)
    @process_list[pid].page_table.each do |page|
      begin
        @mem.dealloc_page page
      rescue PageFault
        @swap.unstore page
      end
    end
    p @process_list
    @process_list.delete pid
    p @process_list
  end
end


class TLB
  attr_reader :tlb, :lru

  def initialize(size = 4)

    @tlb = {}
    @lru = []
    @size = size
  end

  def lookup(page)

    (0...@size).each do | |
      if @tlb[page] != nil
        return @tlb[page]
      end
    end
    #LRU Miss
    RKernel.instance.mem.frame_table.each do |k, v|
      if v == page
        set(page, k)
        return @tlb[page]
      end
    end
    raise PageFault
  end

  def set(key, value)
    @tlb.delete(@lru.pop) if @lru.size >= @size
    @tlb[key] = value
    lru_update(key)
  end

  private
  def lru_update(key)
    @lru.unshift(@lru.delete(key)|| key)
  end

end
