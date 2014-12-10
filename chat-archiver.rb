require 'sinatra'
require 'sinatra/partial'
require 'slack/client'
require 'rubygems'
require 'json'
require 'date'

set :partial_template_engine, :erb

require_relative 'models'

SLACK_API_TOKEN=ENV["SLACK"]

def create_channel(argument)
  channel = Channel.first_or_create
  channel.name = argument
  channel.save
end

def sync_slack_clients(client)
  @users_data = JSON.parse(client.users.list)
  @channel_members_data = @users_data["members"]

  p "******"
  puts @channel_members_data
  p "******"

  process_and_create(@channel_members_data)
end

def process_and_create(members_data_hash)
  p "******"
  puts "members_data_hash"
  puts members_data_hash
  p "*****"

  #Members are listed in alphabetical order by first name
  members_data_hash.length.times do |member_number|

    p "*********"
    puts "member_number"
    puts member_number
    p "*********"

    puts "*********"
    puts "members_data_hash[member_number]"
    puts members_data_hash[member_number]
    puts "*********"

    puts "update_or_create_user_attributes"
    puts update_or_create_user_attributes(members_data_hash[member_number])
    update_or_create_user_attributes(members_data_hash[member_number])
  end
end

def update_or_create_user_attributes(member_data_hash_in_alphabetical_order)
  p "********"
  puts "user_information_hash"
  user_information_hash = member_data_hash_in_alphabetical_order
  p user_information_hash
  p "********"

  method_name(user_information_hash)
end

def method_name(user_information_hash)
  user_information_hash = user_information_hash
    @slack_id = user_information_hash["id"]

    @name = user_information_hash["name"]

    @profile = user_information_hash["profile"]

    @first_name = @profile["first_name"]

    @last_name = @profile["last_name"]

    @image_24 = @profile["image_24"]

    @image_32 = @profile["image_32"]

    @image_48 = @profile["image_48"]

    @image_72 = @profile["image_72"]

    @image_192 = @profile["image_192"]

    @image_original = @profile["image_original"]

    @title = @profile["title"]

    @email = @profile["email"]

    time = Time.now

    @updated_at = time

    user = User.first_or_create(:slack_id => @slack_id, :name => @name, :first_name => @first_name, :last_name => @last_name, :image_24 => @image_24, :image_32 => @image_32,:image_48 => @image_48,:image_72 => @image_72,:image_192 => @image_192,:image_original => @image_original,:title => @title,:email => @email,:updated_at => @created_at)

    p "*** user user user user user user user user user user user user ******"
    puts "user"
    puts user
    puts user.class
    p "*** user user user user user user user user user user user user ******"

  update_or_create_users(user)
end

def update_or_create_users(user)

  @users << user

  if @users.save
    #users are saved
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


helpers do
  def default_channel
    @default_channel ||= Channel.last
  end
end

get "/" do

  erb :home
end

get("/users") do
  @users = Channel.last.users

  erb :users
end

get "/archives" do
  @archives = Channel.last.archives

  erb :archives
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

post "/chats" do
  @archives = Channel.last.archives
  puts "@archives"
  puts @archives
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

    p "**** @ts *****"
    puts @ts
    p "*****"

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

post "/notes" do

  note_attrs = params[:note]
  p archive = params[:archive_id]

  @current_archive = Archive.get(archive)

  @note = Note.new(note_attrs)

  @current_archive.notes << @note

  @current_archive.save


  if @current_archive.save
     # my_account is valid and has been saved
    else
      puts 'notes errors any'
      puts @current_archive.notes.any? { |note| note.errors.any? }

      @current_archive.notes.each do |note|
       note.errors.each do |error|
         p error
       end
     end
  end

  if @note.saved?()
    redirect "/archive/#{@current_archive.id}"
  else
    redirect "/"
  end

end

put "/notes/:note_id" do
  note_id = params[:note_id]
  note_attrs = params[:note]

  note = Note.get(note_id)
  note.update(note_attrs)

  if request.xhr?
    partial :'partials/note', :locals => { :note => note }
  else
    redirect "/archive/#{note.archive_id}"
  end
end

delete "/notes/:note_id" do
  note_id = params[:note_id]
  note_attrs = params[:note]

  note = Note.get(note_id)
  note.destroy

  if request.xhr?
    note_id
  else
    redirect "/archive/#{note.archive_id}"
  end
end

post "/chats/:num" do
  num = params[:num]
  @archives = default_channel.archives
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