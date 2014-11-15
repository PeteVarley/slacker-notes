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
  last_message_data = JSON.parse(client.channels.history(:channel=>'C030C7R5F',:count=>[:id]))
  message_data = last_message_data["messages"]
  last_message_hash = message_data[0]
  @last_message = last_message_hash["text"]
  @chat = Chat.create(:text => @last_message)
  @chats << @chat
  @chats.save

  if @chat.saved?()
    redirect("/chat/#{@chat.id}")
  else
    erb(:chat)
  end
  erb :chat
end

get("/chat/:id") do
  @chat = Chat.get params[:id]

  body(erb(:chat))
end