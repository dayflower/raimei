require 'raimei/version'

module Raimei
  # The {Raimei::Navigation Raimei::Navigation} is a page navigation class,
  # but it only manage page numbers.
  #
  # If you want to manage offsets of records, you can use
  # {Raimei::Pager Raimei::Pager} instead.
  #
  # == Terms
  # In following typical navigation:
  #
  # <tt><<< << 5 6 [7] 8 9 >> >>></tt>
  #
  # [<tt><<<</tt>]  The {#leading} page.  (typically 1)
  # [<tt><<</tt>]   The {#backward} page.
  # [+5+]           The {#first} visible page on the navigation.
  # [+[7]+]           The {#current} page.
  # [+9+]           The {#last} visible page on the navigation.
  # [<tt>>></tt>]   The {#forward} page.
  # [<tt>>>></tt>]  The {#trailing} page.  (typically the total number of pages)
  #
  # == Examples
  # @example
  #   nav = Raimei::Navigation.new(:total_pages         => 10,
  #                                :pages_on_navigation => 5,
  #                                :current_page        => 7)
  #   
  #   puts "<<< " if nav.leading?
  #   puts "<< "  if nav.backward?
  #   
  #   nav.each do |page|
  #     puts "#{page}"
  #     puts "*" if page.current?
  #     puts " "
  #   end
  #   
  #   puts ">> "  if nav.forward?
  #   puts ">>> " if nav.trailing?
  #   
  #   # <<< << 5 6 7* 8 9 >>>
  #
  class Navigation
    include Enumerable

    # @return [Integer] total pages for the navigation
    attr_reader :total_pages

    # @return [Integer] count of pages for visible area on the navigation
    attr_reader :pages_on_navigation

    # @param [Hash] options options
    # @option options [Integer] :total_pages  total pages for the navigation
    # @option options [Integer] :pages_on_navigation(0)  count of pages for visible area on the navigation (0 for unlimited pages)
    # @option options [Integer] :current_page(1)  the current page number
    def initialize(options)
      options = {
        :current_page => 1
      }.merge(options)

      @total_pages         = options[:total_pages]
      @pages_on_navigation = options[:pages_on_navigation]
      @current             = options[:current_page]

      @pages_on_navigation = 0  if @pages_on_navigation < 0
    end

    # @attribute [r] current
    # @return [Integer] the current page number (1 origin)
    def current
      @current
    end
    alias current_page current

    # @attribute [w] current
    def current=(page)
      return page if leading.nil? || trailing.nil?

      raise ArgumentError.new("invalid page number: #{page}") if page < leading || page > trailing

      @current = page
    end
    alias current_page= current=

    # Determine whether the supplied page number is current page or not.
    #
    # @param [Integer] page page number (1 origin)
    # @return [Boolean]
    def current?(page)
      @current == page
    end
    alias current_page? current?

    # @attribute [r] first
    # @return [Integer] first page number on visible area of the navigation (1 origin)
    def first
      return nil if leading.nil?

      return leading if @pages_on_navigation <=0

      a = @current - (@pages_on_navigation - 1) / 2
      if a < leading
        a = leading
      end

      x = @total_pages - @pages_on_navigation + 1
      if x < leading
        x = leading
      end

      if x < a
        a = x
      end

      return a
    end
    alias first_page first
    alias from first

    # @attribute [r] last
    # @return [Integer] last page number on visible area of the navigation (1 origin)
    def last
      return nil if leading.nil? || trailing.nil?

      return trailing if @pages_on_navigation <=0

      b = first + @pages_on_navigation - 1
      if b > trailing
        b = trailing
      end
      return b
    end
    alias last_page last
    alias to last

    # Top page number (1 origin).
    # Returns 1 for most cases.
    #
    # @attribute [r] leading
    # @return [Integer] top page number (1 origin)
    # @return [nil] returns nil when the navigation has no page
    def leading
      (@total_pages > 0) ? 1 : nil
    end
    alias leading_page leading

    # @attribute [r] leading?
    # @return [Boolean] visibility of the leadinging page on the navigation
    def leading?
      return false if first.nil?
      first > 1
    end
    alias leading_page? leading?

    # Bottom page number (1 origin).
    # Result will be equivalent to the total pages for most cases.
    #
    # @attribute [r] trailing
    # @return [Integer] bottom page number (1 origin)
    # @return [nil] returns nil when the navigation has no page
    def trailing
      (@total_pages > 0) ? @total_pages : nil
    end
    alias trailing_page trailing

    # @attribute [r] trailing?
    # @return [Boolean] visibility of the final page on the navigation
    def trailing?
      return false if trailing.nil? || last.nil?
      last < trailing
    end
    alias trailing_page? trailing?

    # Previous page number (1 origin).
    #
    # @attribute [r] prev
    # @return [Integer] previous page number (1 origin)
    # @return [nil] returns nil when the previous page does not exist
    def prev
      prev? ? @current - 1 : nil
    end
    alias prev_page prev
    alias previous prev
    alias previous_page prev

    # @attribute [r] prev?
    # @return [Boolean] whether previous page does exist or not
    def prev?
      @current > 1
    end
    alias prev_page? prev?
    alias previous? prev?
    alias previous_page? prev?

    # Next page number (1 origin).
    #
    # @attribute [r] next
    # @return [Integer] next page number (1 origin)
    # @return [nil] returns nil when the next page does not exist
    def next
      next? ? @current + 1 : nil
    end
    alias next_page next

    # @attribute [r] next?
    # @return [Boolean] whether next page does exist or not
    def next?
      @current < @total_pages
    end
    alias next_page? next?

    # Page number for next navigation page (1 origin).
    #
    # @attribute [r] forward
    # @return [Integer] forward page number (1 origin)
    # @return [nil] returns nil when the forward page does not exist
    def forward
      return nil if trailing.nil?
      return nil if @current.nil?             || @current <= 0
      return nil if @pages_on_navigation.nil? || @pages_on_navigation <= 0

      result = @current + @pages_on_navigation

      (result > trailing) ? nil : result
    end
    alias forward_page forward

    # @attribute [r] forward?
    # @return [Boolean] whether forward page does exist or not
    def forward?
      ! forward.nil?
    end
    alias forward_page? forward?

    # Page number for previous navigation page (1 origin).
    #
    # @attribute [r] backward
    # @return [Integer] backward page number (1 origin)
    # @return [nil] returns nil when the backward page does not exist
    def backward
      return nil if leading.nil?
      return nil if @current.nil?             || @current <= 0
      return nil if @pages_on_navigation.nil? || @pages_on_navigation <= 0

      result = @current - @pages_on_navigation

      (result < leading) ? nil : result
    end
    alias backward_page backward
    alias back backward
    alias back_page backward

    # @attribute [r] backward?
    # @return [Boolean] whether backward page does exist or not
    def backward?
      ! backward.nil?
    end
    alias backward_page? backward?
    alias back? backward?
    alias back_page? backward?

    # @return [AsNumeric] enumerator for numeric page numbers
    #
    # @example
    #   nav.as_numeric.each do |page|
    #     puts page   # => 2, 3, 4 ...
    #     puts "*" if nav.current?(page)
    #   end
    def as_numeric
      return [] if first.nil? || last.nil?

      AsNumeric.new(first, last)
    end

    # Enumerator for numeric page numbers
    class AsNumeric
      include Enumerable

      # @api private
      # @private
      def initialize(first, last)   # :nodoc:
        @first = first
        @last  = last
      end

      # Iterates each page number in visible area of the navigation.
      #
      # @yieldparam [Integer] page page number
      # @return [void]
      def each(&block)
        (@first .. @last).each(&block)
      end
    end

    # Iterates each {Page} in visible area of the navigation.
    #
    # @yieldparam [Page] page the {Page} object
    # @return [void]
    #
    # @example
    #   nav.each do |page|
    #     puts page.page
    #     puts "*" if page.current?
    #   end
    def each
      if block_given?
        return if first.nil? || last.nil?

        (first .. last).each do |page|
          yield Page.new(page, current?(page))
        end
      else
        return Enumerator.new(self)
      end
    end

    # Page object for {Raimei::Navigation}
    class Page
      # @return [Integer] the page number
      attr_reader :page

      # @api private
      # @private
      def initialize(page, is_current = false)    # :nodoc:
        @page    = page
        @current = is_current
      end

      # @attribute [r] current?
      # @return [Boolean] whether the page is the current page on the navigation or not
      def current?
        @current
      end
    end
  end
end
