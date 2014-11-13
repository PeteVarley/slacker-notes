require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'])

class Record
  include DataMapper::Resource

  property :id, Serial
  property :name, String, { :required => true }
  property :website, String, { :format => :url }


  has n, :notes, { :child_key => [:record_id]}
end

class Note
  include DataMapper::Resource

  property :id, Serial
  property :note_title, String
  property :note_subjects, String
  property :note_time_stamp, String
  property :note_content, String

  belongs_to :record
end

DataMapper.finalize
DataMapper.auto_upgrade!