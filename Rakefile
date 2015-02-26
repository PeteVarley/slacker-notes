# create channel and create/ updates users should be part of the sign in process now.
require_relative 'slacker-notes.rb'

require 'json'


task :create_users do

  @users = Channel.last.users
  client = Slack::Client.new(token: SLACK_API_TOKEN)

  create_or_update_users(client)

end