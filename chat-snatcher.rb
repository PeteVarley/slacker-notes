require 'sinatra'
require 'sinatra/partial'
require 'slack/client'
require 'rubygems'
require 'json'
require 'date'

require_relative 'models'


SLACK_API_TOKEN=ENV["SLACK"]

class SlackUserImporter
  def initialize(client)
    @client = client
  end
end

helpers do
  def default_record
    @default_record ||= Record.last
  end
end

# def create_users

#   @users = Record.last.users

#   client = Slack::Client.new(token: SLACK_API_TOKEN)

#   puts 'client'
#   puts client = Slack::Client.new(token: SLACK_API_TOKEN)

#   @users_data = JSON.parse(client.users.list)

#   @users_data = @users_data["members"]

#   @users_data.count.times do |user|
#     user_hash = @users_data[user]


#     p "******************"
#     p user_hash
#     p "*******************"


#     @slack_id = user_hash["id"]

#     @name = user_hash["name"]
#     puts "*********"
#     puts "name"
#     puts @name

#     @profile = user_hash["profile"]
#     puts "*********"
#     puts "profile"
#     puts @profile

#     @first_name = @profile["first_name"]
#     puts "*********"
#     puts "first name"
#     puts @first_name

#     @last_name = @profile["last_name"]
#     puts "*********"
#     puts "last name"
#     puts @last_name

#     @image_24 = @profile["image_24"]
#     puts "*********"
#     puts "image_24"
#     puts @image_24

#     @image_32 = @profile["image_32"]
#     puts "*********"
#     puts "image_32"
#     puts @image_32

#     @image_48 = @profile["image_48"]
#     puts "*********"
#     puts "image_48"
#     puts @image_48

#     @image_72 = @profile["image_72"]
#     puts "*********"
#     puts "image_72"
#     puts @image_72

#     @image_192 = @profile["image_192"]
#     puts "*********"
#     puts "image_192"
#     puts @image_192

#     @image_original = @profile["image_original"]
#     puts "*********"
#     puts "image_original"
#     puts @image_original

#     @title = @profile["title"]
#     puts "*********"
#     puts "title"
#     puts @title

#     @email = @profile["email"]
#     puts "*********"
#     puts "email"
#     puts @email

#     @user = User.create(:slack_id => @slack_id, :name => @name, :first_name => @first_name, :last_name => @last_name, :image_24 => @image_24, :image_32 => @image_32,:image_48 => @image_48,:image_72 => @image_72,:image_192 => @image_192,:image_original => @image_original,:title => @title,:email => @email)

#     @users << @user

#     if @users.save
#       #valid
#     else
#       puts 'user save errors any'
#       @users.any? { |user| user.errors.any? }
#       @users.each do |user|
#         user.errors.each do |user|
#           p user
#         end
#       end
#     end

#   end
# end

# get "/" do

#   erb :home
# end

get("/users") do
  @users = Record.last.users


  p "******************"
  p @users
  p "******************"

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

  number = number_param[:chat_number]

  client = Slack::Client.new(token: SLACK_API_TOKEN)

  @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>number))

  puts "message data"
  puts @message_data
  @messages_data = @message_data["messages"]

  puts "next message data pattern"
  puts @messages_data

  @messages_data.count.times do |message|

    message_hash = @messages_data[message]

    @user = message_hash["user"]

    @text = message_hash["text"]

    @attachments = message_hash["attachments"]


    puts "attachments"
    puts @attachments.class
    if @attachments.class == Array
      @attachments.count.times do |attachment|
        attach_hash = @attachments[attachment]

        @title = attach_hash["title"]
        puts "title"
        puts @title
        puts "title_link"
        @title_link = attach_hash["title_link"]
        puts @title_link
        puts "attach text"
        @attach_text = attach_hash["text"]
        puts "fallback"
        @fallback = attach_hash["fallback"]
        puts @fallback
        puts "thumb_url"
        @thumb_url = attach_hash["thumb_url"]
        puts @thumb_url
        puts "from_url"
        @from_url = attach_hash["from_url"]
        puts @from_url
        puts "thumb_width"
        @thumb_width = attach_hash["thumb_width"]
        puts @thumb_width
        puts "thumb_height"
        @thumb_height = attach_hash["thumb_height"]
        puts @thumb_height

      end
    end

    @ts = message_hash["ts"]

    @chat = Chat.create(:user => @user,:text => @text,:ts => @ts,:attachments => @attachments,:title => @title,:title_link => @title_link,:attach_text => @attach_text,:fallback => @fallback,:thumb_url =>@thumb_url,:from_url => @from_url,:thumb_width => @thumb_width,:thumb_height => @thumb_height)

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

  @users = User.all

  @users.each do |user|
    user["slack_id"]
    user["name"]
  end

  erb(:archive)
end