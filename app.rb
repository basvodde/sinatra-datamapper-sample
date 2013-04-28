require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class Article
  include DataMapper::Resource

  property :id, Serial
  property :title, String
  property :content, Text

  def self.parse_json(body)
    json = JSON.parse(body)
    ret = { :title => json['article']['title'], :content => json['article']['content'] }
    ret 
  end

end

DataMapper.finalize.auto_upgrade!

get '/' do
  erb :index
end

get '/articles' do
  @articles = Article.all
  erb :'articles/index'
end

post '/articles' do
  data = Article.parse_json(request.body.read)
  article = Article.new(data)  
  if article.save
    status 201
  else
    status 500
  end
end

#curl -v -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"widget":{"title":"this is title","content":"some_name"}}' http://localhost:4567/articles

