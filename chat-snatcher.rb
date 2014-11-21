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

  @messages_data = @message_data["messages"]

  @messages_data.count.times do |x|

    message_hash = @messages_data[x]


    @user = message_hash["user"]

    @text = message_hash["text"]

    @ts = message_hash["ts"]

    @chat = Chat.create(:text => @text)

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

get("/users") do

  puts 'default record'
  @users = default_record.users

  client = Slack::Client.new(token: SLACK_API_TOKEN)

  @users_data = JSON.parse(client.users.list)

  puts 'client.users.method'
  puts client.users.methods

  # @user_info = JSON.parse(client.users.info(token: SLACK_API_TOKEN,user: 'U02NQ4BEQ'))

  # puts 'user info'
  # p @user_info

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