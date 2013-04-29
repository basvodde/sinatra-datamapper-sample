require 'rubygems'
require 'sinatra'
require 'data_mapper'
require 'json'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/dev.db")

class POne
  include DataMapper::Resource
  property :id, Serial
  property :licno, String
  property :tax_ref, String
  property :status, String 

  def self.parse_json(body)
    json = JSON.parse(body)
    ret = { :licno => json['p_1']['licno'], :tax_ref => json['p_1']['tax_ref'], :status => json['p_1']['status'] }
    ret 
  end

end

DataMapper.finalize.auto_upgrade!

get '/' do
  erb :index
end

get '/p_ones' do
  @p_ones = POne.all
  erb :'articles/index'
end

post '/p_ones' do
  data = POne.parse_json(request.body.read)
  p_one = POne.new(data)  
  if p_one.save
    status 201
  else
    status 500
  end
end

#curl -v -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"widget":{"title":"this is title","content":"some_name"}}' http://localhost:4567/articles

