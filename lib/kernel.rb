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

  # Command Interpreter
  # This takes the contents of a tape file, parses out the data, and then enqueues it to be run.
  # It is queued so the user can step through every operation and see the contents of memory
  # @param [String] tape
  def feed(tape)
    tokr = /(\d+)\s+(\w+)\s+([^#]+)/     # Split out the pid, opcode, and the arguments as one string
    tape.split("\n").each do |line|
      md = line.match(tokr)
      pid = md[1].to_i
      op = md[2]
      args = md[3]

      if op.match /[aA]lloc/
        a = args.split(" ").map { |i| i.to_i } #each operation has a different way of handling arguments
        load :pid => pid, :op => :alloc, :text => a[0], :data => a[1]
      elsif op.match(/\d+/)
        load :pid => pid, :op => :alloc, :text => op.to_i, :data => args.to_i
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
        load :pid => pid, :op => :read, :segment => seg, :offset => off, :size => size
      end
    end
  end

  #helper method for loading ops
  def load(op)
    @ops.unshift(op)
  end

  def step
    op @ops.pop unless @ops.empty?
  end

  # command processor
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
      end
    end
    @process_list.delete pid
  end
end


# This is a simple hash based TLB, meant to simulate lookup of a frame number
# when you know the page.
# It uses the LRU algorithm implemented with a ruby array. When an entry is
# used, it is removed from the array and thenrequeued to the back. When a new
# entry is inserted, the replaced value is popped off the top
class TLB
  attr_reader :tlb, :lru

  def initialize(size = 4)

    @tlb = {}
    @lru = []
    @size = size
  end


  def lookup(page)


    if @tlb[page] != nil
      return @tlb[page]     #TLB Hit
    end

    #TLB Miss
    RKernel.instance.mem.frame_table.each do |frame, f_page|   #look for the page in the frame table
      if f_page == page
        set(page, frame)
        return @tlb[page]
      end
    end
    # The page was not found in the frame table. This shouldn't happen because pages know if they are swapped.
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
