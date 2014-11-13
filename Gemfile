source "https://rubygems.org"

gem 'sinatra'
gem 'sinatra-partial'
gem 'data_mapper'
gem 'rake'
gem 'faker'
gem 'slack-client'

group :development do
  gem "sqlite3"
  gem "dm-sqlite-adapter"
  gem "dotenv"
  gem "rerun"
  gem 'better_errors'
  gem 'binding_of_caller'

end

group :production do
  gem 'dm-postgres-adapter'
  gem 'pg'
end
