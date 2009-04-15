require 'rubygems'
require 'twitter'
require 'actionpack'
require 'action_view'
require 'tumblr'

TWITTER_USERNAME   = "xyz"
TWITTER_PASSWORD   = "xyz"

TUMBLR_USERNAME    = "xyz"
TUMBLR_PASSWORD    = "xyz"

TIMEFRAME = 86400
TWITTER_REGEXP = /[@]+[A-Za-z0-9-_]+/


include ActionView::Helpers::TagHelper

content = "<ul>"
twitter = Twitter::Client.new(:login => TWITTER_USERNAME, :password => TWITTER_PASSWORD)
new_dictionary_timeline = twitter.timeline_for(:user, :id => TWITTER_USERNAME, :since => Time.now - TIMEFRAME) do |status|
  next if status.created_at.to_i < Time.now.to_i - TIMEFRAME
  linked_status = status.text.gsub(TWITTER_REGEXP) do |l|
    content_tag(:a, l, :href => "http://twitter.com/#{l.slice(1, l.length)}" )
  end
  content << content_tag(:li, linked_status)
end
content << "</ul>"
content << content_tag(:a, "Follow me here", :href => "http://twitter.com/#{TWITTER_USERNAME}")

unless content.blank?
  Tumblr::API.write(TUMBLR_USERNAME, TUMBLR_PASSWORD) do
    regular(content, "Tweets for #{Date.today}")
  end
end