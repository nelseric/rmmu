require "singleton"
class RKernel
  include Singleton
  OPS = [:alloc, :halt, :write, :read]

  PHYSICAL_SIZE = 4096
  PAGE_SIZE = 512
  SWAP_SIZE = 10240
  TLB_SIZE = 4

  attr_reader :mem, :swap, :process_list, :tlb

  def initialize
    @mem = Memory.new(PHYSICAL_SIZE, PAGE_SIZE)
    @swap = SwapMemory.new(SWAP_SIZE, PAGE_SIZE)
    @tlb = TLB.new(TLB_SIZE)
    @process_list = []
  end

  def op(args)
    case (args[:op])
      when :alloc
        @process_list[args[:pid]] = RProcess.new args[:pid], args[:text], args[:data]
      when :halt
        @process_list[args[:pid]].page_table.each do |page|
          @mem.dealloc_page page
        end
        @process_list.delete_at args[:pid]
    end
  end
end

class RProcess

  attr_accessor :pid, :page_table

  def initialize(pid, text, data)
    @page_table = []
    @pid = pid

    data_p = (Float(data) / RKernel::PAGE_SIZE).ceil
    text_p = (Float(text) / RKernel::PAGE_SIZE).ceil
    (0...text_p).each do |i|
      p = RKernel.instance.mem.alloc_page
      p.id = "P#{pid} Text #{i}"
      @page_table.push p
    end
    (0...data_p).each do |i|
      p = RKernel.instance.mem.alloc_page
      p.id = "P#{pid} Data #{i}"
      @page_table.push p
    end
    p @page_table

    @text_start = 0
    @data_start = RKernel::PAGE_SIZE * text_p


  end

  # @param [Integer] Process local address of memory
  def read(addr)

  end

  # @param [Integer] Process local address of memory
  def write(addr)

  end
end


class Memory
  attr_accessor :frame_table

  def initialize(size = 4096, page_size = 512)
    @size = size
    @page_size = 512
    @num_frames = @size / @page_size
    @frame_table = {}
  end

  def alloc_page
    fn = free_frame
    @frame_table[fn] = Page.new
  end

  def dealloc_page(page)
    @frame_table.delete RKernel.instance.tlb.lookup(page)
  end

  def free_frame
    (0...@num_frames).each do |i|
      if @frame_table[i] == nil
        return i
      end
    end
    raise NoMemoryError
  end
end

class TLB
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
        return   @tlb[page]
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

class SwapMemory
  def initialize(size = 10240, page_size = 512)

  end

end

class Page
  attr_accessor :id

  def initialize(descr = "")
    @id = descr
  end

  def to_s
    @id
  end

  def read

  end

  def write

  end
end


class PageFault < Exception

end