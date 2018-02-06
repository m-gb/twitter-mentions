#!/usr/bin/env ruby

require 'oauth'
require 'json'
require 'twitter'

username = ARGV[0]
method = ARGV[1]

@consumer_key, @consumer_secret = File.read('./consumer_key.txt').split("\n")
@access_token, @access_secret = File.read('./access_token.txt').split("\n")

def use_oauth(username)
  # Returns a consumer object which is required to request an oauth access token.
  consumer = OAuth::Consumer.new( @consumer_key, @consumer_secret,
                                  { site: "https://api.twitter.com/",
                                    scheme: :header })
  # Returns an oauth access token which can be used to communicate with the Twitter API.
  oauth_token = OAuth::AccessToken.new(consumer, @access_token, @access_secret)
  # Searches tweets mentioning the username.
  response = oauth_token.get("https://api.twitter.com/1.1/search/tweets.json?q=%40#{username}", result_type: 'recent')
  parsed = JSON.parse(response.body)
  tweets = []
  parsed['statuses'].each do |status| 
    tweets << "#{status['user']['screen_name']}: #{status['text']}"
  end
  puts tweets.take(5)
end

def use_twitter(username)
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = @consumer_key
    config.consumer_secret = @consumer_secret
  end
  client.search("@#{username}", result_type: 'recent').take(5).map do |status|
    puts "#{status.user.screen_name}: #{status.text}"
  end
end

unless username
  puts 'Please enter a Twitter username to search for:'
  username = gets.chomp
end

if method == 'twitter'
  use_twitter(username)
else
  use_oauth(username)
end
