#!/usr/bin/env ruby

require 'twitter'

username = ARGV[0]
count = ARGV[1]

unless username
  puts 'Please enter a Twitter username:'
  username = gets.chomp
end

unless count
  count = 5
end

consumer_key, consumer_secret = File.read('./consumer_key').split("\n")

client = Twitter::REST::Client.new do |config|
  config.consumer_key = consumer_key
  config.consumer_secret = consumer_secret
end

client.search("@#{username}", result_type: 'recent').take(count).collect do |tweet|
  puts "#{tweet.user.screen_name}: #{tweet.text}"
end
