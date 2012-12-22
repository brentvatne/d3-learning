require 'sinatra'

get '/' do
  erb :home
end

get '/scatter' do
  erb :scatter
end

get '/bar' do
  erb :bar
end
