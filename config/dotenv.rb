if ENV['RACK_ENV'] != 'production'
  require 'dotenv'
  Dotenv.load('.env')
end
