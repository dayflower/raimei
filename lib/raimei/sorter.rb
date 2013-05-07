require 'raimei/version'

module Raimei
  # {Raimei::Sorter Raimei::Sorter} is a manager for sorting criterion
  # of sortable table.
  # {Raimei::Sorter} itself DOES NOT sort records :)
  #
  # To use {Raimei::Sorter}, you have to require +'raimei/sorter'+ explicitly.
  #
  # == Examples
  # @example
  #   sorter = Raimei::Sorter.new([ [:foo, :asc], [:bar, :desc], [:baz, :asc] ])
  #   
  #   params[:order] = sorter.link_for("bar")   # => "bar-"
  #   sorter.sort_by! params[:order]
  #   sorter.order                              # => [ [:bar, :desc], [:foo, :asc], [:baz, :asc] ]
  #   
  #   params[:order] = sorter.link_for("baz")   # => "baz,bar-"
  #   sorter.sort_by! params[:order]
  #   sorter.order                              # => [ [:baz, :asc], [:bar, :desc], [:foo, :asc] ]
  #   
  #   # You can supply sorter.order to ORM's sorting method
  #   records = Record.all.order_by(sorter.order)
  #
  class Sorter
    # @return [Array] default order specification
    attr_accessor :default_order

    # @return [Boolean] single criterion mode
    attr_accessor :single

    # @example
    #   default_order = [
    #     [ :foo, :asc  ],
    #     [ :bar, :desc ],
    #   ]
    #   
    #   sorter = Raimei::Sorter.new(default_order)
    #
    # @param [Array] default_order default order specification
    # @param [Hash] options options
    # @option options [Boolean] :single single criterion mode
    def initialize(default_order, options={})
      @default_order = default_order
      @current_order = @default_order

      @single = !! options[:single]
    end

    # @attribute [r] order
    # @return [Array] current order specification
    def order
      @current_order
    end

    # Reset current order to default.
    #
    # @return [Sorter] self
    def reset
      @current_order = @default_order

      self
    end

    # Create new sorter that reflects specified new order.
    #
    # @example
    #   sorter = Raimei::Sorter.new([ [:foo, :asc], [:bar, :desc], [:baz, :asc] ])
    #   sorter.sort("bar,baz-").order
    #   # => [ [:bar, :asc], [:baz, :asc], [:foo, :asc] ]
    #
    # @see #sort!
    #
    # @param [String] orders new order specification
    # @return [Sorter] new sorted {Sorter} instance
    def sort(orders)
      result = self.dup
      result.sort! orders
      return result
    end

    # Change current order with specified order.
    # @see #sort
    #
    # @param [String] orders
    # @return [Sorter] self
    def sort!(orders)
      new_order = []
      consumed  = {}

      orders.to_s.split(%r{\s* , \s*}xmo).each do |field|
        order = field.gsub!(/-$/, "") ? :desc : :asc
        field.gsub! /\+$/, ""
        field = field.to_sym

        new_order << [ field, order ]
        consumed[field] = true

        break if @single
      end

      @current_order.each do |row|
        next if consumed.delete(row[0].to_sym)

        new_order << row
      end

      # remove nonexistent fields
      unnec_keys = consumed.keys
      new_order.select! { |row| ! unnec_keys.index(row[0]) }

      @current_order = new_order

      self
    end

    # Create new sorter in which the specified field is topmost criterion.
    #
    # @example
    #   sorter = Raimei::Sorter.new([ [:foo, :asc], [:bar, :desc], [:baz, :asc] ])
    #   sorter.sort_by("bar").order
    #   # => [ [:bar, :desc], [:foo, :asc], [:baz, :asc] ]
    #
    # @see #sort_by!
    #
    # @param [String] field sort field name (and direction)
    # @return [Sorter] new sorted {Sorter} instance
    def sort_by(field)
      result = self.dup
      result.sort_by! field
      return result
    end

    # Change current order with specified field.
    # @see #sort_by
    #
    # @param [String] field sort field name (and direction)
    # @return [Sorter] self
    def sort_by!(field)
      field = field.to_s
      if field.gsub!(/-$/, "")
        new_order = :desc
      elsif field.gsub!(/\+$/, "")
        new_order = :asc
      else
        order = order_of(field)
        return self if order.nil?

        if top?(field)
          # reverse if the field is top
          new_order = (order == :asc) ? :desc : :asc
        else
          new_order = order
        end
      end

      trailing  = (new_order == :desc) ? "-" : ""

      sort! "#{field}#{trailing}"

      self
    end

    # @param [Hash] options options (optional)
    # @option options [Boolean] :single single criterion mode
    # @return [String] current sorting parameters represented in string compacted
    def current_link(options = {})
      options = { :single => @single }.merge(options)

      if options[:single]
        cur_order = [ @current_order[0] ]
      else
        cur_order = compact_array(@current_order, @default_order)
      end

      fields = []
      cur_order.each do |row|
        trailing = (row[1] == :desc) ? "-" : ""
        fields << "#{row[0]}#{trailing}"
      end

      return fields.join(",")
    end

    # Returns new sorting parameters with which the specified field's sorting
    # criterion is topmost.
    #
    # @example
    #   sorter = Raimei::Sorter.new([ [:foo, :asc], [:bar, :desc], [:baz, :asc] ])
    #   sorter.link_for("bar")
    #   # => "bar-"
    #
    # @param [String] field sorting field name (and direction)
    # @param [Hash] options options
    # @option options [Boolean] :single single criterion mode
    # @return [String] sorting parameters represented in string compacted
    def link_for(field, options = {})
      return sort_by(field).current_link(options)
    end

    # Returns current sorting direction for the specified field.
    #
    # @param [String] field field name
    # @return [Symbol] current sorting direction (+:asc+ and +:desc+) for the specified field
    # @return [nil] returns nil if unexistent field is specified
    def order_of(field)
      field = field.to_s
      @current_order.each do |row|
        if row[0].to_s == field
          return row[1].to_sym
        end
      end

      nil
    end

    # @param [String] field field name
    # @return [Boolean] whether the specified field's sorting criterion is top or not
    def top?(field)
      row = @current_order[0]

      row[0].to_s == field.to_s
    end

    # @param [String] field field name
    # @return [Boolean] true when the specified field's criterion is top and ascending order
    def top_asc?(field)
      return false unless top?(field)

      @current_order[0][1].to_sym == :asc
    end

    # @param [String] field field name
    # @return [Boolean] true when the specified field's criterion is top and descenging order
    def top_desc?(field)
      return false unless top?(field)

      @current_order[0][1].to_sym == :desc
    end

    # @param [String] field field name
    # @return [Boolean] whether the specified field's sorting order is ascending or not
    def asc?(field)
      order_of(field) == :asc
    end

    # @param [String] field field name
    # @return [Boolean] whether specified field's sorting order is descending or not
    def desc?(field)
      order_of(field) == :desc
    end

    private

    # @api private
    # @private
    def compact_array(target, default)    # :nodoc:
      return [] if target.equal?(default)

      target  = target.dup
      default = default.dup

      result  = []
      stock   = []
      stored  = {}

      while target.length > 0
        if stored.delete(default[0][0])
          # already stored
          default.shift
          next
        end

        top = target.shift

        if top == default[0]
          stock << top
          default.shift
          next
        end

        result += stock
        stock = []

        result << top

        stored[top[0]] = true
      end

      default.select! { |item| ! stored[item[0]] }

      result += default

      return result
    end
  end
end
