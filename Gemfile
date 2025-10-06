source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.6'

gem 'rails', '~> 8.0.2'

gem 'puma', '~> 6.4'
gem 'bootsnap', '>= 1.4.2', require: false
# gem "activerecord-sqlserver-adapter", "~> 7.1.0"
# gem "tiny_tds", "~> 2.1"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem "web-console"
  gem "listen", "~> 3.7"
  gem "spring"
end

group :test do
  gem "rspec-rails", "~> 6.1"
end

gem 'mysql2'

gem 'pry-rails'
gem 'pry-doc'
gem 'pry-stack_explorer'
gem 'pry-byebug'

gem 'rubyXL'
