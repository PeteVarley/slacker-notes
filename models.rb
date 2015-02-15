require 'data_mapper'
require 'dm-timestamps'
require 'sinatra'
require 'omniauth'


DataMapper::Logger.new($stdout, :debug)

if ENV['RACK_ENV'] != "production"
  require 'dotenv'
  Dotenv.load('.env')
  DataMapper.setup(:default, "sqlite:chat_archiver.db")
end

if ENV['RACK_ENV'] == "production"
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Team
  include DataMapper::Resource

  property :id, Serial
  property :team_name, String
  property :team_id, String

  has n, :users
end

class Channel
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :website, String, { :format => :url }

  has n, :archives
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :slack_id, String
  property :name, String
  property :first_name, String
  property :last_name, String
  property :image_24, Text
  property :image_32, Text
  property :image_48, Text
  property :image_72, Text
  property :image_192, Text
  property :image_original, Text
  property :title, String
  property :email, String
  property :updated_at, DateTime
  property :created_at, DateTime
  property :token, String

  belongs_to :team, :required => false

end

class Archive
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :ts, DateTime
  belongs_to :channel

  has n, :chats
  has n, :notes
end

class Chat
  include DataMapper::Resource

  property :id, Serial
  property :user, Text
  property :text, Text
  property :attachments, Text
  property :ts, Text
  property :attachments, Text
  property :title, Text
  property :title_link, Text, { :format => :url }
  property :attach_text, Text
  property :fallback, Text
  property :thumb_url, Text, { :format => :url }
  property :from_url, Text, { :format => :url }
  property :thumb_width, Text
  property :thumb_height, Text


  belongs_to :archive
end

class Note
  include DataMapper::Resource

  property :id, Serial
  property :user, Text
  property :note_title, Text
  property :note_text, Text
  property :note_tags, Text

  belongs_to :archive
end

DataMapper.finalize
DataMapper.auto_upgrade!

helpers do
    include Rack::Utils
    alias_method :h, :escape_html
end