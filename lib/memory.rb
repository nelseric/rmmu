require_relative "./kernel"

# The frame table is a hash, with the frame number as the key, pointing to pages
# When a page is swapped to virtual memory, the LRU algorithm is used, implemented in a similar way to
# the TLB
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
      fn = free_frame #get the first available frame
    rescue NoMemoryError
      swap # or swap the LRU frame
      retry
    end
    lru_update fn
    @frame_table[fn] = Page.new # Make a new page reference, and save it. The program sets the page description
  end

  #free up a page
  def swap
    lru = @lru.pop # swap the LRU frame
    puts "Swapping #{lru}"
    s = @frame_table[lru]
    @frame_table.delete lru
    s.swap # set the  page swap bit
    RKernel.instance.swap.store s
  end

  def unswap(page)
    begin
      fn = free_frame
    rescue NoMemoryError
      swap #make room for the page
      retry
    end
    @frame_table[fn] = page
    RKernel.instance.swap.unstore page
    page.unswap #clear the page swap bit
    lru_update fn
  end

  def read(page)
    begin
      raise PageFault if page.swapped #if we know the page is swapped, don't look it up
      k = RKernel.instance.tlb.lookup(page) #if for some reason the swap bit isn't set, but not in memory, this will
                                            # throw a page fault too
    rescue PageFault
      unswap page #load the page, and try the lookup again
      retry
    end
    lru_update k
  end

  # This will delete a page
  # It works on both swapped and unswapped pages
  def dealloc_page(page)
    unless page.swapped
      k = RKernel.instance.tlb.lookup(page)
      @lru.delete(k)
      @frame_table.delete k
    else
      RKernel.instance.swap.unstore page
    end
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
  # moves the key to the back of the queue
  def lru_update(key)
    @lru.unshift(@lru.delete(key)|| key)
  end

end

# Swap memory is very similar to real memory, except it is not designed for direct reading like real memory is
# Since Pages are only logical, and have no real value, I don't need to store any data, just keep a reference to the
# page and a file number. If there was a real page file, this file number could be used to access the page.
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

  # Look for the first free file
  def free_file
    (0...@num_frames).each do |i|
      if @file_table[i] == nil
        return i
      end
    end
    raise NoMemoryError
  end


end

# The page class acts as a kind of logical page ID, instead of a physical page of memory.
# It is an intermediary between a process page table and the frame_table and virtual memory
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
