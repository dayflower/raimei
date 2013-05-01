# Raimei

Rai-mei (雷鳴) is the very tiny pagination library.

It DOES ...

* Manage pager's page numbers (via {Raimei::Navigation} and {Raimei::Pager})
* Calculate record offset for specified page (via {Raimei::Pager})

It DOES NOT ...

* Render pager
* Retrieve records from any storage

This library is independent of ActiveRecord and other ORMs,
and also does not rely on Rails and other frameworks.

## Usage

### Terms

In following typical navigation:

`<<< << 5 6 [7] 8 9 >> >>>`

<dl>
  <dt><tt>&lt;&lt;&lt;</tt></dt>
  <dd>The {Raimei::Navigation#leading #leading} page.  (typically 1)</dd>
  <dt><tt>&lt;&lt;</tt></dt>
  <dd>The {Raimei::Navigation#backward #backward} page.</dd>
  <dt><tt>5</tt></dt>
  <dd>The {Raimei::Navigation#first #first} visible page on the navigation.</dd>
  <dt><tt>[7]</tt></dt>
  <dd>The {Raimei::Navigation#current #current} page.</dd>
  <dt><tt>9</tt></dt>
  <dd>The {Raimei::Navigation#last #last} visible page on the navigation.</dd>
  <dt><tt>&gt;&gt;</tt></dt>
  <dd>The {Raimei::Navigation#forward #forward} page.</dd>
  <dt><tt>&gt;&gt;&gt;</tt></dt>
  <dd>The {Raimei::Navigation#trailing #trailing} page.  (typically the total number of pages)</dd>
</dl>

### Raimei::Navigation

The {Raimei::Navigation} is a page navigation class, but it only manage
page numbers.
If you want to manage offsets of records, you can use {Raimei::Pager}
instead.

```ruby
nav = Raimei::Navigation.new(:total_pages         => 10,
                             :pages_on_navigation => 5,
                             :current_page        => 7)

puts "<<< " if nav.leading?
puts "<< "  if nav.backward?

nav.each do |page|
  puts "#{page}"
  puts "*" if page.current?
  puts " "
end

puts ">> "  if nav.forward?
puts ">>> " if nav.trailing?

# <<< << 5 6 7* 8 9 >>>
```

### Raimei::Pager

The {Raimei::Pager} is a descendant of {Raimei::Navigation},
and provides record offset management in addition.

```ruby
pager = Raimei::Pager.new(:total_entries       => 100,
                          :page_size           => 20,
                          :pages_on_navigation => 5,
                          :current_page        => 3)

# Mongoid flavour ORM example :)
records = Record.all.limit(pager.page_size).skip(pager.offset_for_current)
records.each do |record|
  puts record
end

puts "#{pager.entries_for_current} records."
puts "(#{pager.top_entry_index_for_current} - #{pager.bottom_entry_index_for_current})"

# see example in Raimei::Navigation for paging navigation.
```

### Raimei::Sorter

{Raimei::Sorter} is a manager for sorting criterion of sortable table.
{Raimei::Sorter} itself DOES NOT sort records :)

To use {Raimei::Sorter}, you have to require `'raimei/sorter'` explicitly.

```ruby
sorter = Raimei::Sorter.new([ [:foo, :asc], [:bar, :desc], [:baz, :asc] ])

params[:order] = sorter.link_for("bar")   # => "bar-"
sorter.sort_by! params[:order]
sorter.order                              # => [ [:bar, :desc], [:foo, :asc], [:baz, :asc] ]

params[:order] = sorter.link_for("baz")   # => "baz,bar-"
sorter.sort_by! params[:order]
sorter.order                              # => [ [:baz, :asc], [:bar, :desc], [:foo, :asc] ]

# You can supply sorter.order to ORM's sorting method
records = Record.all.order_by(sorter.order)
```

## Installation

Add this line to your application's Gemfile:

    gem 'raimei'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install raimei

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
