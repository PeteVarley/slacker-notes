require 'sinatra'
require 'sinatra/partial'
require 'slack/client'
require 'rubygems'
require 'json'
require 'date'

set :partial_template_engine, :erb

require_relative 'models'

SLACK_API_TOKEN=ENV["SLACK"]

helpers do
  def default_channel
    @default_channel ||= Channel.last
  end
end

def create_archives
  @archives = Channel.last.archives
end

def create_current_archive
  @current_archive = Archive.create(:ts => Time.now)
end

def create_channel(argument)
  channel = Channel.first_or_create
  channel.name = argument
  channel.save
end

def sync_slack_clients(client)
  @users_data = JSON.parse(client.users.list)
  @channel_members_data = @users_data["members"]

  list_member_data(@channel_members_data)
end

def list_member_data(members_data_hash)
  #Members are listed in alphabetical order by first name
  members_data_hash.length.times do |member_number|
    update_or_create_user_attributes(members_data_hash[member_number])
  end
end

def update_or_create_user_attributes(member_data_hash_in_alphabetical_order)
  member_information_hash = member_data_hash_in_alphabetical_order

  update_or_create_users(member_information_hash)
end

def update_or_create_users(member_information_hash)
  member_information_hash = member_information_hash
    #the following variables are named after the corresponding data items passed to this application from the Slack API
    @slack_id = member_information_hash["id"]

    @name = member_information_hash["name"]

    @profile = member_information_hash["profile"]

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

  save_users(user)
end

def save_users(user)

  @users << user

  if @users.save
    #users are saved
  else
    #add partial that displays an appropriate message on the home page
  end
end

get "/" do
  erb :home
end

def client
  client = Slack::Client.new(token: SLACK_API_TOKEN)
end

get("/users") do
  @users = Channel.last.users

  erb :users
end

get "/archives" do
  create_archives

  erb :archives
end

get("/archive/:id") do
  @archive = Archive.get params[:id]

  @users = User.all

  @users.each do |user|
    user["slack_id"]
    user["name"]
  end

  erb :archive
end

# "/chats" do ############################################################################################################

def create_current_archvie
  @current_archive = Archive.create(:ts => Time.now)
  add_current_archive_to_archives(@current_archive)
end

def add_current_archive_to_archives(current_archive)
  @archives << @current_archive
end

def save_archives(archives)
  @archives.save
end

def archive_this_chat
  fetch_number_of_messages_user_wants_to_save
end

def fetch_number_of_messages_user_wants_to_save
  fetch_number_param = params().fetch("number")
  number_of_messages(fetch_number_param)
end

def number_of_messages(fetch_number_param)
  number_of_messages = fetch_number_param[:chat_number]
  request_channel_history(number_of_messages)
end

def request_channel_history(number_of_messages)
  number = number_of_messages

  channel_history_requested = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>number))
  message_hashes_from_channel_history(channel_history_requested)
end

def message_hashes_from_channel_history(messages_requested)
  messages_array = messages_requested["messages"]

  loop_through_message_hashes(messages_array)
end

def loop_through_message_hashes(messages_array)
  messages_array.length.times do |message_number|
    get_each_hash_from_messages_array(messages_array,message_number)
  end
end

def get_each_hash_from_messages_array(messages_array,message_number)
  slack_message_hash = messages_array[message_number]

  build_message_hash_for_chat_archive(slack_message_hash)
end

def build_message_hash_for_chat_archive(slack_message_hash)

  @user = slack_message_hash["user"]

  @text = slack_message_hash["text"]

  @attachments = slack_message_hash["attachments"]

  @ts = slack_message_hash["ts"]

  if @attachments.class == Array
    @attachments.length.times do |attachment|
      slack_attachment_hash = @attachments[attachment]

      @title = slack_attachment_hash["title"]

      @title_link = slack_attachment_hash["title_link"]

      @attach_text = slack_attachment_hash["text"]

      @fallback = slack_attachment_hash["fallback"]

      @thumb_url = slack_attachment_hash["thumb_url"]

      @from_url = slack_attachment_hash["from_url"]

      @thumb_width = slack_attachment_hash["thumb_width"]

      @thumb_height = slack_attachment_hash["thumb_height"]
    end
  end

  @chat = Chat.create(:user => @user,:text => @text,:ts => @ts,:attachments => @attachments,:title => @title,:title_link => @title_link,:attach_text => @attach_text,:fallback => @fallback,:thumb_url =>@thumb_url,:from_url => @from_url,:thumb_width => @thumb_width,:thumb_height => @thumb_height)
  create_chat(@chat)
end

def create_chat(chat)
  @current_archive.chats << @chat
  save_chat(@current_archive)
end

def save_chat(current_archive)
  @current_archive.save
end

def errors_saving_chat
  if @current_archive.save
   # my_account is valid and has been saved
    if @chat.saved?()
      redirect "/archive/#{@current_archive.id}"
    else
      erb :error
    end
  else
    erb :error
  end
end

post "/chats" do
  create_archives
  create_current_archvie

  archive_this_chat
  errors_saving_chat
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