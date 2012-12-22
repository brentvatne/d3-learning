require './app'

map '/assets' do
  require 'sprockets'

  environment = Sprockets::Environment.new
  environment.append_path 'public'
  environment.append_path 'coffeescripts'
  environment.append_path 'json'
  environment.append_path 'components'
  run environment
end

run Sinatra::Application
