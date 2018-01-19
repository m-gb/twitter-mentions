#!/usr/bin/env ruby

require 'oauth'
require 'json'
require 'twitter'

screenname = ARGV[0]
method = ARGV[1]

@consumer_key, @consumer_secret = File.read('./consumer_key').split("\n")
@access_token, @access_secret = File.read('./access_token').split("\n")

def use_oauth(screenname)
  # Returns a consumer object which is required to request an oauth access token.
  consumer = OAuth::Consumer.new( @consumer_key, @consumer_secret,
                                  { site: "https://api.twitter.com/",
                                    scheme: :header })
  # Returns an oauth access token which can be used to communicate with the Twitter API.
  oauth_token = OAuth::AccessToken.new(consumer, @access_token, @access_secret)
  # Searches tweets mentioning the screenname.
  response = oauth_token.get("https://api.twitter.com/1.1/search/tweets.json?q=%40#{screenname}", result_type: 'recent')
  parsed = JSON.parse(response.body)
  tweets = []
  parsed['statuses'].each do |status| 
    tweets << "#{status['user']['screen_name']}: #{status['text']}"
  end
  puts tweets.take(5)
end

def use_twitter(screenname)
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = @consumer_key
    config.consumer_secret = @consumer_secret
  end
  client.search("@#{screenname}", result_type: 'recent').take(5).map do |tweet|
    puts "#{tweet.user.screen_name}: #{tweet.text}"
  end
end

unless screenname
  puts 'Please enter a Twitter screen name to search for:'
  screenname = gets.chomp
end

if method == 'twitter'
  use_twitter(screenname)
else
  use_oauth(screenname)
end
