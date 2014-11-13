require 'sinatra'
require 'sinatra/partial'
require 'better_errors'
require 'slack/client'

require_relative 'config/dotenv'
require_relative 'models'

Dotenv.load

SLACK_API_TOKEN=ENV["SLACK"]

client = Slack::Client.new(token: SLACK_API_TOKEN)

puts client.users.list
#puts client.channels.list
#puts client.channels.history('C1234567')