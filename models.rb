require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Record
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :website, String, { :format => :url }

  has n, :users, { :child_key => [:record_id]}
  has n, :archives, { :child_key => [:record_id]}
  has n, :chats, :through => :archives
end

class User
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :deleted, Boolean

  belongs_to :record
  has n, :chats
  has n, :infos
end

class Info
  include DataMapper::Resource

  property :id, Serial
  property :name, String

  belongs_to :user
  has n, :profiles
end

class Profile
  include DataMapper::Resource

  property :id, Serial
  property :first_name, String
  property :last_name, String
  property :image_24, String

  belongs_to :info
end

class Archive
  include DataMapper::Resource

  property :id, Serial
  property :name, String
  property :ts, String

  belongs_to :record
  has n, :chats, { :child_key => [:record_id]}
end

class Chat
  include DataMapper::Resource

  property :id, Serial
  property :user, String
  property :text, String
  property :ts, String

  belongs_to :archive
  belongs_to :user
end

DataMapper.finalize
DataMapper.auto_upgrade!