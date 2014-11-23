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

  erb :home
end

get "/archives" do
  @archives = default_record.archives

  erb :archives
end

post "/chats" do
  @archives = default_record.archives
  @current_archive = Archive.create(:ts => Time.now)
  @archives << @current_archive
  @archives.save

  puts @current_archive.id

  number_param = params().fetch("number")

  puts 'number'
  number = number_param[:chat_number]
  p number


  client = Slack::Client.new(token: SLACK_API_TOKEN)
  @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>number))

  @messages_data = @message_data["messages"]



  @messages_data.count.times do |x|

    message_hash = @messages_data[x]


    @user = message_hash["user"]

    @text = message_hash["text"]

    @ts = message_hash["ts"]

    @chat = Chat.create(:user => @user,:text => @text,:ts => @ts)

    @current_archive.chats << @chat


    if @current_archive.save
     # my_account is valid and has been saved
    else
      puts 'chats errors any'
      puts @current_archive.chats.any? { |chat| chat.errors.any? }

      @current_archive.chats.each do |chat|
       chat.errors.each do |error|
         p error
       end
     end
   end



  end

  if @chat.saved?()
    redirect "/archive/#{@current_archive.id}"
  else
    redirect "/"
  end
end

post "/chats/:num" do
  num = params[:num]
  @archives = default_record.archives
  @current_archive = Archive.create(:ts => Time.now)
  @archives << @current_archive
  @archives.save

  client = Slack::Client.new(token: SLACK_API_TOKEN)
  @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>num))

  @messages_data = @message_data["messages"]

  # @messages_data.count.times do |x|

  #   message_hash = @messages_data[x]


  #   @user = message_hash["user"]

  #   @text = message_hash["text"]

  #   @ts = message_hash["ts"]

  #   @chat = Chat.create(:text => @text)

  #   @current_archive.chats << @chat


  #   if @current_archive.save
  #    # my_account is valid and has been saved
  #   else
  #     puts 'chats errors any'
  #     puts @current_archive.chats.any? { |chat| chat.errors.any? }

  #     @current_archive.chats.each do |chat|
  #      chat.errors.each do |error|
  #        p error
  #      end
  #    end
  #  end



  # end

  # if @chat.saved?()
  #   erb(:chats)
  # else
  #   redirect "/"
  # end
  erb(:chats)
end

get("/archive/:id") do
  @archive = Archive.get params[:id]
  puts 'archive id'
  puts @archive.id
  puts "archive.chats"
  puts @archive.chats

  erb(:archive)
end

get("/users") do

  puts 'default record'
  @users = default_record.users

  client = Slack::Client.new(token: SLACK_API_TOKEN)

  @users_data = JSON.parse(client.users.list)

  @users_data = @users_data["members"]

  @users_data.count.times do |x|
    user_hash = @users_data[x]


    @name = user_hash["name"]
    @id = user_hash["id"]


    @user = User.create(:name => @name)
    puts "user name"
    puts @user.name
    @users << @user
    @users.save
    puts @user.id


  end


  erb(:users)
end