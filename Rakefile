require_relative 'chat-archiver.rb'
require 'json'

channel_name = "Web-fundamentals"


task :create_channel do
  create_channel(channel_name)
end

task :create_users do

  @users = Channel.last.users
  client = Slack::Client.new(token: SLACK_API_TOKEN)
  puts 'client'
  puts client

  @users_data = JSON.parse(client.users.list)
  puts 'users_data'
  puts @users_data

  @user_data = @users_data["members"]
  puts @user_data

  @user_data.count
  puts "User data count"
  puts @user_data.count

  @user_data.count.times do |user|
    user_hash = @user_data[user]

    p 'user'
    p user

    p "****************"
    puts 'User hash'
    p user_hash
    p "****************"

    @slack_id = user_hash["id"]
    puts "*********"
    puts 'slack id'
    puts @slack_id

    @name = user_hash["name"]
    puts "*********"
    puts "name"
    puts @name

    @profile = user_hash["profile"]
    puts "*********"
    puts "profile"
    puts @profile

    @first_name = @profile["first_name"]
    puts "*********"
    puts "first name"
    puts @first_name

    @last_name = @profile["last_name"]
    puts "*********"
    puts "last name"
    puts @last_name

    @image_24 = @profile["image_24"]
    puts "*********"
    puts "image_24"
    puts @image_24

    @image_32 = @profile["image_32"]
    puts "*********"
    puts "image_32"
    puts @image_32

    @image_48 = @profile["image_48"]
    puts "*********"
    puts "image_48"
    puts @image_48

    @image_72 = @profile["image_72"]
    puts "*********"
    puts "image_72"
    puts @image_72

    @image_192 = @profile["image_192"]
    puts "*********"
    puts "image_192"
    puts @image_192

    @image_original = @profile["image_original"]
    puts "*********"
    puts "image_original"
    puts @image_original

    @title = @profile["title"]
    puts "*********"
    puts "title"
    puts @title

    @email = @profile["email"]
    puts "*********"
    puts "email"
    puts @email

    time = Time.now

    puts '@user'
    puts @user.class

    @created_at = time
    puts "*********"
    puts "created at"
    puts @created_at


      @user = User.first_or_create(:slack_id => @slack_id, :name => @name, :first_name => @first_name, :last_name => @last_name, :image_24 => @image_24, :image_32 => @image_32,:image_48 => @image_48,:image_72 => @image_72,:image_192 => @image_192,:image_original => @image_original,:title => @title,:email => @email,:created_at => @created_at)
      @users << @user

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