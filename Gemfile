source 'https://rubygems.org'

# -- Core
gem 'rails', '4.0.13'
gem 'arel',  github: 'rails/arel', branch: '4-0-stable'
gem 'pg', '0.15.1'

# -- Sidekiq related
gem 'sidekiq', '>= 2.13.0'
gem 'slim', '>= 2.0.0', require: false
gem 'sinatra', '>= 1.4.3', require: false # if you require 'sinatra' you get the DSL extended to Object
gem 'yajl-ruby'

# -- App needs
gem 'redis-objects'

# gem 'redis'
# gem 'acts-as-taggable-on', '~> 2.4.1'
# gem 'sanitize'
# gem 'kaminari', '0.14.1'
# gem 'crunchbase', '0.3.1', git: 'git://github.com/cocoonventures/crunchbase'

# -- Infrastructure
gem 'guard'
gem 'launchy'
# gem 'activerecord-postgres-hstore'

gem 'sass', require: 'sass'
gem 'sshkit', '0.0.34' # this is the only way capistrano v3 works DON'T CHANGE!!!
gem 'jquery-rails'
gem 'turbolinks'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  #gem 'sprockets-rails', '~> 2.0.0.rc4'
  gem 'sass-rails',      '~> 4.0.0'
  gem 'coffee-rails',    '~> 4.0.0'
  gem 'less-rails'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  #gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.3.0'
end



group :test do
  gem 'capybara', '2.1.0' #, '1.1.2'
  gem 'capybara-screenshot'
  gem 'capybara-webkit', '~> 1.0.0' #git: 'https://github.com/thoughtbot/capybara-webkit.git', branch: 'master'
  gem 'database_cleaner'

  gem 'guard-spork', '1.2.0'
  gem 'spork', '0.9.2'
  gem 'factory_girl_rails', '4.2.1'
end

group :development do
  # non-test related guards
  gem 'guard-livereload'
  gem 'guard-bundler'
  
  # Nice dev errors
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'meta_request'

  gem 'guard-sidekiq'
  gem 'annotate', :git => 'git://github.com/ctran/annotate_models.git'
  gem 'binding_of_caller'
  # gem 'capistrano', tag: '3.0.0.pre13', github: 'capistrano/capistrano', require: false #, branch: 'v3'
  # gem 'capistrano-rbenv', github: "cocoonventures/rbenv"
  gem 'factory_girl_rails', '4.2.1'
end

group :test, :development do
  gem 'rspec-rails', '~>2.13.2'
  gem 'guard-rspec', '1.2.1'
  gem 'debugger'
end

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  #gem 'sdoc', require: false
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
gem 'jbuilder', '~> 1.0.1'

# Use unicorn as the app server
gem 'unicorn'