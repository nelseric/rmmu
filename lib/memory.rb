require_relative "./kernel"


class Memory
  attr_accessor :frame_table, :lru

  def initialize(size = 4096, page_size = 512)
    @size = size
    @page_size = page_size
    @num_frames = @size / @page_size
    @frame_table = {}
    @lru = []
  end

  def alloc_page
    begin
      fn = free_frame
    rescue NoMemoryError
      swap
      retry
    end
    lru_update fn
    @frame_table[fn] = Page.new
  end

  #free up a page
  def swap
    lru = @lru.pop
    puts "Swapping #{lru}"
    s = @frame_table[lru]
    @frame_table.delete lru
    s.swap
    RKernel.instance.swap.store s
  end

  def unswap(page)
    begin
      fn = free_frame
    rescue NoMemoryError
      swap
      retry
    end
    @frame_table[fn] = page
    RKernel.instance.swap.unstore page
    page.unswap
    lru_update fn
  end

  def read(page)
    begin
      raise PageFault if page.swapped
      k = RKernel.instance.tlb.lookup(page)
    rescue PageFault
      unswap page
      retry
    end
    lru_update k
  end

  def dealloc_page(page)
    k = RKernel.instance.tlb.lookup(page)
    @lru.delete(k)
    @frame_table.delete k
  end

  def free_frame
    (0...@num_frames).each do |i|
      if @frame_table[i] == nil
        return i
      end
    end
    raise NoMemoryError
  end

  private
  def lru_update(key)
    @lru.unshift(@lru.delete(key)|| key)
  end

end

class SwapMemory
  attr_accessor :file_table

  def initialize(size = 10240, page_size = 512)
    @size = size
    @page_size = page_size
    @num_frames = @size / @page_size
    @file_table = {}
  end

  def store(page)
    fn = free_file
    @file_table[fn] = page
  end

  def unstore(page)
    @file_table.delete lookup(page)
  end

  def lookup(page)
    @file_table.each do |k, v|
      if v == page
        return k
      end
    end
  end

  def free_file
    (0...@num_frames).each do |i|
      if @file_table[i] == nil
        return i
      end
    end
    raise NoMemoryError
  end


end


class Page
  attr_accessor :id, :swapped

  def initialize(descr = "")
    @id = descr
    @swapped = false
  end

  def swap
    @swapped = true
  end

  def unswap
    @swapped = false
  end

  def to_s
    @id
  end
end


class PageFault < Exception
end
