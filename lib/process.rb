require_relative "./kernel"


# The process page table is a simple ordered array, with the pages stored in segment order
# When reading, the offset is calculated and the Page object is read. With the page object,
# you can read the page, or deallocate it
class RProcess

  attr_accessor :pid, :page_table

  def initialize(pid, text, data)
    @page_table = []
    @pid = pid

    #number of pages in each section
    data_p = (Float(data) / RKernel::PAGE_SIZE).ceil
    text_p = (Float(text) / RKernel::PAGE_SIZE).ceil

    #create pages in order
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
    # memory page offsets in the page table
    @text_os = 0
    @data_os = text_p
  end

  def read(seg, offset, size)
    page_range = (Float((offset%RKernel::PAGE_SIZE) + size)/RKernel::PAGE_SIZE).ceil
    page_offset = offset / RKernel::PAGE_SIZE
    if seg == :text
      (page_offset...page_offset + page_range).each do |i|
        RKernel.instance.mem.read @page_table[@text_os + i]
      end
    elsif seg == :data
      (page_offset...page_offset + page_range).each do |i|
        RKernel.instance.mem.read @page_table[@data_os + i]
      end
    end
  end


  # There isn't really a distinction between reads and writes in this system
  alias :write :read
  #def write(seg, offset, size)
  #
  #end
end
