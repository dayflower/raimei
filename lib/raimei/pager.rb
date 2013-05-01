require 'raimei/version'
require 'raimei/navigation'

module Raimei
  # The {Raimei::Pager Raimei::Pager} is a descendant of
  # {Raimei::Navigation Raimei::Navigation}, and provides record offset
  # management in addition.
  #
  # == Terms
  # See {Raimei::Navigation}'s terms description.
  #
  # == Examples
  # @example
  #   pager = Raimei::Pager.new(:total_entries       => 100,
  #                             :page_size           => 20,
  #                             :pages_on_navigation => 5,
  #                             :current_page        => 3)
  #   
  #   # Mongoid flavour ORM example :)
  #   records = Record.all.limit(pager.page_size).skip(pager.offset_for_current)
  #   records.each do |record|
  #     puts record
  #   end
  #   
  #   puts "#{pager.entries_for_current} records."
  #   puts "(#{pager.top_entry_index_for_current} - #{pager.bottom_entry_index_for_current})"
  #   
  #   # see example in Raimei::Navigation for paging navigation.
  #
  class Pager < Navigation
    include Enumerable

    # @return [Integer] total record entries for the pager
    attr_reader :total_entries

    # @return [Integer] number of record entries for each page
    attr_reader :entries_per_page
    alias page_size entries_per_page

    # @return [Integer] offset of the first record on the current page
    attr_reader :offset

    # @param [Hash] options options
    # @option options [Integer] :total_entries  total record entries for the pager
    # @option options [Integer] :page_size(20)  number of record entries for each page
    # @option options [Integer] :pages_on_navigation(0)  count of pages for visible area on the pager (0 for unlimited pages on pager navigation)
    # @option options [Integer] :current_page(1)  the current page number
    # @option options [Integer] :offset  the offset of the first record on the current page (optional)
    def initialize(options)
      options = {
        :page_size           => 20,
        :pages_on_navigation => 0,
      }.merge(options)

      @total_entries    = options[:total_entries]
      @entries_per_page = options[:entries_per_page] || options[:page_size]

      num_pages = (@total_entries + @entries_per_page - 1) / @entries_per_page
      options[:total_pages] = num_pages

      cur = options.delete(:current_page)

      super options

      if options.has_key?(:offset)
        self.offset = options[:offset]
      else
        self.current = cur.nil? ? 1 : cur
      end
    end

    # Offset of the first record on the current page.
    #
    # @attribute [w] offset
    def offset=(o)
      @offset = o
      self.current = 1 + @offset / @entries_per_page
    end

    # The current page number (1 origin)
    #
    # @attribute [rw] current
    # @return [Integer]
    def current=(page)
      super
      @offset = @entries_per_page * (current - 1)
    end

    # @attribute [r] offset_for_current
    # @return [Integer] the offset of the first record on the current page (0 origin)
    def offset_for_current
      offset_for_page(current)
    end
    alias offset_for_current_page offset_for_current

    # @attribute [r] entries_for_current
    # @return [Integer] the number of record entries on the current page
    def entries_for_current
      entries_for_page(current)
    end
    alias entries_for_current_page entries_for_current

    # @attribute [r] top_entry_index_for_current
    # @return [Integer] the offset of the first record on the current page (1 origin)
    def top_entry_index_for_current
      top_entry_index_for_page(current)
    end
    alias top_entry_index_for_current_page top_entry_index_for_current

    # @attribute [r] bottom_entry_index_for_current
    # @return [Integer] the offset of the last record on the current page (1 origin)
    def bottom_entry_index_for_current
      bottom_entry_index_for_page(current)
    end
    alias bottom_entry_index_for_current_page bottom_entry_index_for_current

    # @attribute [r] offset_for_first
    # @return [Integer] the offset of the first record on the first page (0 origin)
    def offset_for_first
      offset_for_page(first)
    end
    alias offset_for_first_page offset_for_first

    # @attribute [r] entries_for_first
    # @return [Integer] the number of record entries on the first page
    def entries_for_first
      entries_for_page(first)
    end
    alias entries_for_first_page entries_for_first

    # @attribute [r] top_entry_index_for_first
    # @return [Integer] the offset of the first record on the first page (1 origin)
    def top_entry_index_for_first
      top_entry_index_for_page(first)
    end
    alias top_entry_index_for_first_page top_entry_index_for_first

    # @attribute [r] bottom_entry_index_for_first
    # @return [Integer] the offset of the last record on the first page (1 origin)
    def bottom_entry_index_for_first
      bottom_entry_index_for_page(first)
    end
    alias bottom_entry_index_for_first_page bottom_entry_index_for_first

    # @attribute [r] offset_for_last
    # @return [Integer] the offset of the first record on the last page (0 origin)
    def offset_for_last
      offset_for_page(last)
    end
    alias offset_for_last_page offset_for_last

    # @attribute [r] entries_for_last
    # @return [Integer] the number of record entries on the last page
    def entries_for_last
      entries_for_page(last)
    end
    alias entries_for_last_page entries_for_last

    # @attribute [r] top_entry_index_for_last
    # @return [Integer] the offset of the first record on the last page (1 origin)
    def top_entry_index_for_last
      top_entry_index_for_page(last)
    end
    alias top_entry_index_for_last_page top_entry_index_for_last

    # @attribute [r] bottom_entry_index_for_last
    # @return [Integer] the offset of the last record on the last page (1 origin)
    def bottom_entry_index_for_last
      bottom_entry_index_for_page(last)
    end
    alias bottom_entry_index_for_last_page bottom_entry_index_for_last

    # @param [Integer] page the page number (1 origin)
    # @return [Integer] the offset of the first record on the specified page (0 origin)
    def offset_for_page(page)
      raise ArgumentError.new("invalid pager condition") if first.nil? || last.nil?
      raise ArgumentError.new("invalid page number: #{page}") if page < first || page > last

      @entries_per_page * (page - 1)
    end

    # @param [Integer] page the page number (1 origin)
    # @return [Integer] the number of record entries on the specified page
    def entries_for_page(page)
      raise ArgumentError.new("invalid pager condition") if first.nil? || last.nil?
      raise ArgumentError.new("invalid page number: #{page}") if page < first || page > last

      if page == last
        (@total_entries - 1) % @entries_per_page + 1
      else
        @entries_per_page
      end
    end

    # @param [Integer] page the page number (1 origin)
    # @return [Integer] the offset of the first record on the specified page (1 origin)
    def top_entry_index_for_page(page)
      return 0 if total_entries <= 0
      return 0 if page <= 0
      return 0 if page > total_entries

      offset_for_page(page) + 1
    end

    # @param [Integer] page the page number (1 origin)
    # @return [Integer] the offset of the last record on the specified page (1 origin)
    def bottom_entry_index_for_page(page)
      return 0 if total_entries <= 0
      return 0 if page <= 0
      return 0 if page > total_entries

      offset_for_page(page) + entries_for_page(page)
    end

    # @return [AsNumeric] enumerator for numeric page numbers
    #
    # @example
    #   pager.as_numeric.each do |page, offset|
    #     puts page   # => 2, 3, 4 ...
    #     puts "*" if page.current?
    #     
    #     records = Record.all.limit(pager.page_size).skip(offset)
    #     records.each do |record|
    #       # ......
    #     end
    #   end
    def as_numeric
      return [] if first.nil? || last.nil?

      AsNumeric.new(self)
    end

    # Enumerator for numeric page numbers
    class AsNumeric
      include Enumerable

      # @api private
      # @private
      def initialize(master)    # :nodoc:
        @master = master
      end

      # Iterates each page number and record offset in visible area of the navigation.
      #
      # @yieldparam [Integer] page page number
      # @yieldparam [Integer] record offset
      # @return [void]
      def each
        if block_given?
          (@master.first .. @master.last).each do |page|
            yield page, @master.offset_for_page(page)
          end

          return self
        else
          return Enumerator.new(self)
        end
      end
    end

    # Iterates each {Page} in visible area of the navigation.
    #
    # @yieldparam [Page] page the {Page} object
    # @return [void]
    #
    # @example
    #   pager.each do |page|
    #     puts page.page
    #     puts "*" if page.current?
    #     
    #     records = Record.all.limit(pager.page_size).skip(page.offset)
    #     records.each do |record|
    #       # ......
    #     end
    #   end
    def each
      if block_given?
        return if first.nil? || last.nil?
        (first .. last).each do |page|
          yield Page.new(self, page)
        end
      else
        return Enumerator.new(self)
      end
    end

    # Page object for {Raimei::Pager}
    class Page
      # @return [Pager]
      attr_reader :pager

      # @return [Integer] the page number
      attr_reader :page

      # @api private
      # @private
      def initialize(pager, page)   # :nodoc:
        @pager   = pager
        @page    = page
      end

      # @attribute [r] offset
      # @return [Integer] record offset for the page
      def offset
        @pager.offset_for_page(@page)
      end

      # @attribute [r] current?
      # @return [Boolean] whether the page is the current page on the navigation or not
      def current?
        @pager.current?(@page)
      end

      # @attribute [r] page_size
      # @return [Integer] the page size of the pager
      def page_size
        @pager.page_size
      end
    end
  end
end
