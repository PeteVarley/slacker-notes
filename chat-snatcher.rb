require 'sinatra'
require 'sinatra/partial'
require 'better_errors'
require 'slack/client'
require 'rubygems'
require 'json'


require_relative 'config/dotenv'
require_relative 'models'

Dotenv.load

SLACK_API_TOKEN=ENV["SLACK"]

#route goes here
# def save_info
#   client = Slack::Client.new(token: SLACK_API_TOKEN)
#   last_message_data = JSON.parse(client.channels.history(:channel=>'C030C7R5F',:count=>1))
#   r = Record.get([1])
#   puts "last_message_data"
#   message_data = last_message_data["messages"]
#   puts "message_data"
#   last_message_hash = message_data[0]
#   last_message = last_message_hash["text"]
#   puts "last_message"
#   p last_message

#   puts r
#   text = Message.new(:text => last_message)
#   r.messages << text
#   r.save
# end

# save_info