require_relative "./kernel"

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

  def write(seg, offset, size)

  end
end
