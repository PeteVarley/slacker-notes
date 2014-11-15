require 'data_mapper'

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'])

class Record
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :website, String, { :format => :url }


  has n, :chats, { :child_key => [:record_id]}
end


class Chat
  include DataMapper::Resource

  property :id, Serial
  property :user, String
  property :text, String
  property :ts, String

  belongs_to :record
end

DataMapper.finalize
DataMapper.auto_upgrade!