source "https://rubygems.org"
ruby "2.1.2"

gem 'sinatra'
gem 'sinatra-partial'
gem 'data_mapper'
gem 'rake'
gem 'slack-client'
gem 'json'
gem 'omniauth'
gem 'omniauth-oauth2'
gem 'omniauth-github'
gem 'omniauth-slack'

group :development do
  gem "sqlite3"
  gem "dm-sqlite-adapter"
  gem "dotenv"
  gem "rerun"
  gem 'better_errors'
  gem 'binding_of_caller'

end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end
