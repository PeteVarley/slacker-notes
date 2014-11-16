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

helpers do
  def default_record
    @default_record ||= Record.last
  end
end

get "/" do
  @chats = default_record.chats

  erb :home
end

get "/archive/:id" do
  @chats = default_record.chats
  client = Slack::Client.new(token: SLACK_API_TOKEN)
  @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>[:id]))
  puts @message_data

  @messages_data = @message_data["messages"]
  puts "@messages_data"
  puts @messages_data

  puts "@message_data.count"
  puts @messages_data.count

  @messages_data.count.times do |x|
    puts "x"
    puts x
    message_hash = @messages_data[x]
    puts "message_hash"
    puts message_hash

    @user = message_hash["user"]
    puts "user"
    puts @user
    @text = message_hash["text"]
    puts "text"
    puts @text
    @ts = message_hash["ts"]
    puts "ts"
    puts @ts
    @chat = Chat.create(:user => @user, :text => @text, :ts => @ts)
    @chats << @chat
    @chats.save


    # puts "X"
    # puts x
    # message_hash = @messages_data[x]
  end


  if @chat.saved?()
    erb(:archive)
  else
    redirect "/archive/:id"
  end

end

get("/chat/:id") do
  @chat = Chat.get params[:id]

  body(erb(:chat))
end