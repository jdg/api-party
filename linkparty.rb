# From: http://railstips.org/2008/7/29/it-s-an-httparty-and-everyone-is-invited
# Author: John Nunemaker

# Delicious API with HTTParty Gem

require 'rubygems'
require 'httparty'
require 'actionpack'
require 'action_view'
require 'tumblr'

DELICIOUS_USERNAME = "xyz"
DELICIOUS_PASSWORD = "xyz"

TUMBLR_USERNAME    = "xyz"
TUMBLR_PASSWORD    = "xyz"

TIMEFRAME = 86400

class Delicious
  include HTTParty
  base_uri 'https://api.del.icio.us/v1'

  def initialize(auth)
    @auth = auth
  end

  # query params that filter the posts are:
  #   tag (optional). Filter by this tag.
  #   dt (optional). Filter by this date (CCYY-MM-DDThh:mm:ssZ).
  #   url (optional). Filter by this url.
  #   ie: posts(:query => {:tag => 'ruby'})
  def posts(options={})
    options.merge!({:basic_auth => @auth})
    # get posts and convert to structs so we can do .key instead of ['key'] with results
    self.class.get('/posts/get', options)
  end

  # query params that filter the posts are:
  #   tag (optional). Filter by this tag.
  #   count (optional). Number of items to retrieve (Default:15, Maximum:100).
  def recent(options={})
    options.merge!({:basic_auth => @auth})
    self.class.get('/posts/recent', options)
  end
end

include ActionView::Helpers::TagHelper
content = "<ul>"
delicious = Delicious.new(:username => DELICIOUS_USERNAME, :password => DELICIOUS_PASSWORD)
links = delicious.recent(:tag => 'iphone', :count => 50)['posts']['post']
links.each do |link|
  if Time.parse(link['time']).to_i > TIMEFRAME
    content << content_tag(:li, content_tag(:a, link['description'], :href => link['href']))
  end
end
content << "</ul>"

unless links.blank?
  Tumblr::API.write(TUMBLR_USERNAME, TUMBLR_PASSWORD) do
    regular(content, "Links for #{Date.today}")
  end
end