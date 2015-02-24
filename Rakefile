# create channel and create/ updates users should be part of the sign in process now.
require_relative 'slacker-notes.rb'

require 'json'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new :specs do |task|
  task.pattern = Dir['spec/**/*_spec.rb']
end

task :default => ['specs']



task :create_users do

  @users = Channel.last.users
  client = Slack::Client.new(token: SLACK_API_TOKEN)

  create_or_update_users(client)

end