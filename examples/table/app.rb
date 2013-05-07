# -*- coding: utf-8 -*-
require 'uri'
require 'raimei/sorter'

configure do
  set :views, settings.root
  set :haml, :escape_html => true, :attr_wrapper => '"', :format => :html5

  DB = Sequel.sqlite    # on-memory database

  DB.create_table :members do
    primary_key :id
    String :name
    String :email
    String :area
  end

  members = DB[:members]
  1.upto(200) do
    members.insert(:name  => Forgery(:name).full_name,
                   :email => Forgery(:internet).email_address,
                   :area  => Forgery(:address).continent)
  end
end

helpers do
  def uri_for(options = {})
    params = {
      :offset    => @pager.offset,
      :page_size => @pager.page_size,
      :order     => @sorter.current_link,
      :keyword   => @keyword,
    }.merge(options)

    params = Hash[ params.select { |k, v| ! v.nil? && ! v.to_s.empty? } ]

    u = URI::HTTP.build(:path => '/',
                        :query => URI.encode_www_form(params))
    uri(u.request_uri, false)
  end
end

get '/' do
  all_members = DB[:members]

  @keyword = params[:keyword] || ""
  if ! @keyword.empty?
    all_members = all_members.where(:name.ilike("%#{@keyword}%"))  \
                             .or(:email.ilike("%#{@keyword}%"))    \
                             .or(:area.ilike("%#{@keyword}%"))
  end

  @sorter = Raimei::Sorter.new([[:name, :asc], [:email, :asc], [:area, :asc]])
  @sorter.sort! params[:order]
  # ORDER BY parameters in Sequel-way
  orders = @sorter.order.map { |f| f[1] == :asc ? f[0] : Sequel.desc(f[0]) }

  # Sequel has its own pagenation, but I use Raimei as example :)
  page_size = params[:page_size].to_i
  page_size = 15  if page_size <= 0
  @pager = Raimei::Pager.new(:total_entries       => all_members.count,
                             :page_size           => page_size,
                             :pages_on_navigation => 9)
  @pager.offset = params[:offset].to_i || 0

  @members = all_members.order(*orders).limit(@pager.page_size, @pager.offset)

  haml :view
end
