require "singleton"
class RKernel
  include Singleton
  OPS = [:alloc, :halt, :write, :read]

  PHYSICAL_SIZE = 4096
  PAGE_SIZE = 512
  PD_SIZE = 10240

  attr_reader :mem, :vmem, :process_list

  def initialize
    @mem = Memory.new(PHYSICAL_SIZE, PAGE_SIZE)
    @vmem = VirtualMemory.new(PD_SIZE, PAGE_SIZE)
    @process_list = []
  end

  def op(args)
    p args
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

  def read(addr)

  end

  def write(offset)

  end
end


class Memory
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
    @frame_table.delete page
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

class VirtualMemory
  def initialize(size = 10240, page_size = 512)

  end

end

class Page
  attr_accessor :id

  def initialize(descr = "")
    @id = descr
  end

  def read

  end

  def write

  end
end
