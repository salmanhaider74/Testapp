source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.7.1'

gem 'activeadmin'
gem 'apollo_upload_server', '2.0.1'
gem 'aws-sdk-kms', '~> 1.11'
gem 'aws-sdk-s3', require: false
gem 'bootsnap', require: false
gem 'daemons'
gem 'devise'
gem 'dwolla_v2', '~> 3.1'
gem 'enumerize'
gem 'faraday'
gem 'graphiql-rails'
gem 'graphql'
gem 'groupdate'
gem 'hellosign-ruby-sdk'
gem 'jbuilder'
gem 'jsonb_accessor'
gem 'jwt'
gem 'lograge'
gem 'money-rails'
gem 'paper_trail'
gem 'pg'
gem 'phonelib'
gem 'plaid'
gem 'puma'
gem 'rack-cors'
gem 'rails', '~> 6.0.3', '>= 6.0.3.6'
gem 'rollbar'
gem 'sass-rails'
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem 'turbolinks'
gem 'twilio-ruby'
gem 'webpacker'
gem 'wicked_pdf'
gem 'wkhtmltopdf-binary'

group :development, :test, :ci do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
end

group :development do
  gem 'annotate'
  gem 'brakeman'
  gem 'listen', '~> 3.5.1'
  gem 'rubocop', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
end

group :test, :ci do
  gem 'minitest-rails', '~> 6.0.0'
  gem 'mocha'
  gem 'timecop'
  gem 'webmock'
end
