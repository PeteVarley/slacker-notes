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

def create_record
    r = Record.new
    r.name = "Big"
    r.save
end

helpers do
  def default_record
    @default_record ||= Record.last
  end
end

def create_users
  puts 'default record'
  @users = Record.last.users

  client = Slack::Client.new(token: SLACK_API_TOKEN)

  @users_data = JSON.parse(client.users.list)

  @users_data = @users_data["members"]

  @users_data.count.times do |x|
    user_hash = @users_data[x]

    @slack_id = user_hash["id"]
    puts "Here is the id"
    puts @slack_id

    @name = user_hash["name"]

    @user = User.create(:slack_id => @slack_id, :name => @name)
    puts "username"
    puts @user.name
    puts ":slack_id"
    puts @user.slack_id
    @users << @user
    puts @users.save
    # @users.save
    # puts @user.id
    if @users.save
      #valid
    else
      puts 'user save errors any'
      @users.any? { |user| user.errors.any? }
      @users.each do |user|
        user.errors.each do |user|
          p user
        end
      end
    end

  end
end

#--------
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
#--------



get "/" do

  erb :home
end

get("/users") do
  @users = default_record.users

  erb :users
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
  puts @archives
  puts "archive.chats"
  puts @archive.chats


  @users = User.all

  @users.each do |user|
    user["slack_id"]
    user["name"]
    puts user["slack_id"]
  end
  puts @users



  erb(:archive)
end