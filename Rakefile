require_relative 'chat-archiver.rb'
require 'json'

channel_name = 'web-fundamentals'

task :create_channel do
  create_channel(channel_name)
end

task :create_users do

  @users = Channel.last.users
  client = Slack::Client.new(token: SLACK_API_TOKEN)

  create_or_update_users(client)

end