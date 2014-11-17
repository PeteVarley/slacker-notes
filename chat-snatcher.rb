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
  @archives = default_record.archives

  erb :home
end

get "/chats/:num" do
  num = params[:num]
  puts "num"
  puts num
  @archives = default_record.archives
  @current_archive = Archive.create(:ts => Time.now)
  @archives << @current_archive
  @archives.save
  puts 'archives'
  puts @archives
  puts 'current archive id'
  puts @current_archive.id

  client = Slack::Client.new(token: SLACK_API_TOKEN)
  @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>num))
  puts "JSON parse"
  puts client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>2)
  puts "message data"
  puts "_____________"
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
    @current_archive.chats << @chat
    @current_archive.save

  end


  if @chat.saved?()
    erb(:chats)
  else
    redirect "/"
  end

end

get("/archive/:id") do
  @archive = Archive.get params[:id]
  puts 'archive id'
  puts @archive.id
  puts "archive.chats"
  puts @archive.chats

  erb(:archive)
end