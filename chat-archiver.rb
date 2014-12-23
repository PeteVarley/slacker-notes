require 'sinatra'
require 'sinatra/partial'
require 'slack/client'
require 'rubygems'
require 'json'
require 'date'
require 'omniauth'

set :partial_template_engine, :erb

require_relative 'models'

SLACK_API_TOKEN=ENV["SLACK"]

helpers do
 #saving for later
end

use Rack::Session::Cookie
use OmniAuth::Builder do
  provider :developer
end

class Developer
  include OmniAuth::Strategy

  option :fields, [:name, :email]
  option :uid_field, :email

  def request_phase
    form = OmniAuth::Form.new(:title => 'User Info', :url => callback_path)
    options.fields.each do |field|
      form.text_field field.to_s.capitalize.gsub('_', ' '), field.to_s
    end
    form.button 'Sign In'
    form.to_response
  end

  uid do
    request.params[options.uid_field.to_s]
  end

  info do
    options.fields.inject({}) do |hash, field|
      hash[field] = request.params[field.to_s]
      puts "&&&&& hash &&&&&"
      puts hash
      hash
    end
  end
end

post '/auth/developer/callback' do

  erb :callback
end


def create_channel(channel_name)
  channel = Channel.first_or_create
  channel.name = channel_name
  channel.save
end

def create_archives
  @archives = Channel.last.archives
end

def create_current_archive
  @current_archive = Archive.create(:ts => Time.now)
end

def create_or_update_users(client)
  parse_users_list(client)
end

def parse_users_list(client)
  # Slack users.list
  #https://api.slack.com/methods/users.list
  users_data = JSON.parse(client.users.list)
  channel_members_data = users_data["members"]

  list_member_data(channel_members_data)
end

def list_member_data(members_data_hash)
  #Members are listed in alphabetical order by first name
  members_data_hash.length.times do |member_number|
    update_or_create_user_attributes(members_data_hash[member_number])
  end
end

def update_or_create_user_attributes(member_data_hash_in_alphabetical_order)
  member_information_hash = member_data_hash_in_alphabetical_order

  update_or_create_member_information_hash(member_information_hash)
end

def time_now
  time = Time.now
end

def update_or_create_member_information_hash(member_information_hash)
  member_information_hash = member_information_hash

    @slack_id = member_information_hash["id"]

    @name = member_information_hash["name"]
    # the following are profile attributes this method is capturing from the Slack API
    # https://api.slack.com/methods/users.list
    @profile = member_information_hash["profile"]

      @first_name = @profile["first_name"]

      @last_name = @profile["last_name"]
      # image is 24 x 24 pixels
      @image_24 = @profile["image_24"]
      # image is 32 x 32 pixels
      @image_32 = @profile["image_32"]
      # image is 48 x 48 pixels
      @image_48 = @profile["image_48"]
      # image is 72 x 72 pixels
      @image_72 = @profile["image_72"]
      # image is 192 x 192 pixels
      @image_192 = @profile["image_192"]

      @image_original = @profile["image_original"]

      @title = @profile["title"]

      @email = @profile["email"]

    @updated_at = time_now

  user = User.first_or_create(:slack_id => @slack_id, :name => @name, :first_name => @first_name, :last_name => @last_name, :image_24 => @image_24, :image_32 => @image_32,:image_48 => @image_48,:image_72 => @image_72,:image_192 => @image_192,:image_original => @image_original,:title => @title,:email => @email,:updated_at => @updated_at)

  add_users_to_user(user)
end

def add_users_to_user(user)
  @users << user
  save_users(@users)
end

def save_users(users)
  if @users.save
    #users are saved
  else
    #add partial that displays an appropriate message on the home page
  end
end

get "/test" do
  puts "_____________ @client_id _____________"
  @client_id = 3012263173.3259470988
  puts @client_id
  #@redirect_uri = params[:redirect_uri]
  #@scope = params[:scope]
  @state = 123
  #@team = params[:team]


  #erb :param_test
  redirect "https://slack.com/oauth/authorize"
end

get "/" do
  erb :archiver
end



get "/archiver" do
  erb :archiver
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
  add_chat_to_current_archive(@chat)
end

def add_chat_to_current_archive(chat)
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


# "/notes" do ############################################################################################################
def get_note_id
  note_id = params[:note_id]
end

def get_note_attrs
  note_attrs = params[:note]
end

def get_archvie_id
  archive = params[:archive_id]
end

def get_current_archive
  @current_archive = Archive.get(get_archvie_id)
end

def create_and_save_note
  create_note
end

def create_note
  @note = Note.new(get_note_attrs)
  add_note_to_current_archive(@note)
end

def add_note_to_current_archive(note)
  get_current_archive.notes << note
  save_current_archive_with_note
end

def save_current_archive_with_note
  if @current_archive.save
   # current archive has been saved

  else
    erb :'error'
  end

  if @note.saved?()
    # note has been saveds
    redirect "/archive/#{@current_archive.id}"
  else
    erb :'error'
  end

end

post "/notes" do
  create_and_save_note
end

put "/notes/:note_id" do
  note = Note.get(get_note_id)
  note.update(get_note_attrs)
end

put "/notes/:note_id" do

  note_attrs = params[:note]

  note = Note.get(get_note_id)
  note.update(note_attrs)

  if request.xhr?
    partial :'partials/notes', :locals => { :note => note }
  else
    redirect "/archive/#{note.archive_id}"
  end
end

delete "/notes/:note_id" do
  note = Note.get(get_note_id)
  note.destroy

  if request.xhr?
    note_id
  else
    redirect "/archive/#{note.archive_id}"
  end
end

# post "/chats/:num" do
#   num = params[:num]
#   @archives = default_channel.archives
#   @current_archive = Archive.create(:ts => Time.now)
#   @archives << @current_archive
#   @archives.save

#   client = Slack::Client.new(token: SLACK_API_TOKEN)
#   @message_data = JSON.parse(client.channels.history(:channel=>ENV["SLACK_CHANNEL"],:count=>num))

#   @messages_data = @message_data["messages"]

#   @messages_data.count.times do |x|

#     message_hash = @messages_data[x]


#     @user = message_hash["user"]

#     @text = message_hash["text"]

#     @ts = message_hash["ts"]

#     @chat = Chat.create(:text => @text)

#     @current_archive.chats << @chat


#     if @current_archive.save
#      # my_account is valid and has been saved
#     else
#       puts 'chats errors any'
#       puts @current_archive.chats.any? { |chat| chat.errors.any? }

#       @current_archive.chats.each do |chat|
#        chat.errors.each do |error|
#          p error
#        end
#      end
#    end



#   end

#   if @chat.saved?()
#     erb(:chats)
#   else
#     redirect "/"
#   end
#   erb(:chats)
# end
