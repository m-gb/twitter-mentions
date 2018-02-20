#!/usr/bin/env ruby

require 'oauth'
require 'json'
require 'twitter'

search_term = ARGV[0]
method = ARGV[1]

def load_files
  begin
    # Reads access_token.txt and consumer_key.txt from the script's directory.
    @consumer_key, @consumer_secret = File.read("#{__dir__}/consumer_key.txt").split("\n")
    @access_token, @access_secret = File.read("#{__dir__}/access_token.txt").split("\n")
    unless [@access_token, @access_secret, @consumer_key, @consumer_secret].all? { |value| value.match(/^([a-zA-Z0-9-])+$/) }
      raise RegexpError.new('One or more key-secret pairs are incorrect, see README.md for more information.')
    end
  rescue Errno::ENOENT => e # Is raised when one of the files is not found.
    puts "File not found, see README.md for more information.\nExiting..."
    exit
  rescue RegexpError => e
    puts "#{e.message}\nExiting..."
    exit
  end
end

def use_oauth(username)
  load_files
  # Returns a consumer object which is required to request an oauth access token.
  consumer = OAuth::Consumer.new( @consumer_key, @consumer_secret,
                                  { site: 'https://api.twitter.com/',
                                    scheme: :header })
  # Returns an oauth access token which can be used to communicate with the Twitter API.
  oauth_token = OAuth::AccessToken.new(consumer, @access_token, @access_secret)
  # Searches tweets mentioning the username.
  begin
    response = oauth_token.get("https://api.twitter.com/1.1/search/tweets.json?q=%40#{username}", result_type: 'recent')
  rescue StandardError
    puts "Network error, please check your internet connection.\nExiting..."
    exit
  end
  parsed = JSON.parse(response.body)
  parsed['statuses'].take(5).map do |status|
    puts "#{status['user']['screen_name']}: #{status['text']}"
  end
end

def use_twitter(username)
  load_files
  client = Twitter::REST::Client.new do |config|
    config.consumer_key = @consumer_key
    config.consumer_secret = @consumer_secret
    config.access_token = @access_token
    config.access_token_secret = @access_secret
  end
  begin
    client.search("@#{username}", result_type: 'recent').take(5).map do |status|
      puts "#{status.user.screen_name}: #{status.text}"
    end
  rescue StandardError
    puts "Network error, please check your internet connection.\nExiting..."
    exit
  end
end

unless search_term
  puts 'Please enter a Twitter username to search for:'
  search_term = gets.chomp
end

if method == 'twitter'
  use_twitter(search_term)
else
  use_oauth(search_term)
end
