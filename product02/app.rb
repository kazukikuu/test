require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?

require 'sinatra/activerecord'
require './models'
require 'open-uri'
require 'json'
require 'net/http'

enable :sessions

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

get '/signup' do
  erb :sign_up
end

post '/signup' do
  user = User.create(
      name: params[:name],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
      )
   if user.persisted?
     session[:user] = user.id
   end
  redirect '/'
end

get '/signin' do
   erb :sign_in
end

post '/signin' do
  user = User.find_by(name: params[:name])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/'
end


get '/signout' do
   session[:user] = nil
   redirect '/'
end


get '/' do
  erb :form
end

get '/list' do
   keyword = params[:keyword]
   uri = URI("https://itunes.apple.com/search")
  uri.query = URI.encode_www_form({term: keyword,country: "JP", media: "music", limit: 10 })
   res = Net::HTTP.get_response(uri)
   returned_json = JSON.parse(res.body)
   json = JSON.parse(res.body)
   @musics = returned_json["results"]
 erb :search
end

post '/answers' do
  Post.create(
  image: params[:image],
  artist: params[:artist],
  album: params[:album],
  url: params[:url],
  comment: params[:comment],
  user_id: current_user.id,
  user_name: current_user.name
  )
redirect '/mypage'
end


get '/mypage' do
  @posts = Post.all
  erb :mypage
end


get '/delete/:id' do
  Post.find(params[:id]).delete
  redirect '/mypage'
end

get '/edit/:id' do
  @posts = Post.find(params[:id])
  erb :edit
end

post '/edit/:id/update' do
  post =  Post.find(params[:id])
  post.comment = params[:comment]
  post.save
  redirect '/mypage'
end

get '/toukou' do
  @posts = Post.all
  erb :toukou
end
