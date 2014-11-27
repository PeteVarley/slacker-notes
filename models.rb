require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)

if ENV['RACK_ENV'] != "production"
  require 'dotenv'
  Dotenv.load('.env')
  DataMapper.setup(:default, "sqlite:wall.db")
end

if ENV['RACK_ENV'] == "production"
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

class Record
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :website, String, { :format => :url }

  has n, :users
  has n, :archives
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :slack_id, String
  property :name, String
  property :first_name, String
  property :last_name, String

  belongs_to :record

end

class Archive
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :ts, String

  belongs_to :record
  has n, :chats
end

class Chat
  include DataMapper::Resource

  property :id, Serial
  property :user, Text
  property :text, Text
  property :ts, Text

  belongs_to :archive
end

DataMapper.finalize
DataMapper.auto_upgrade!