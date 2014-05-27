require 'sinatra'
require 'active_record'
require 'digest/sha1'
require 'sinatra/flash'
require 'logger'
require 'yaml'
require_relative 'model/mongodb'
require 'mongoid'
require 'mongo'
Mongoid.load!("config/mongodb.yml")

include Mongo

host = ENV['MONGO_RUBY_DRIVER_HOST'] || 'localhost'
port = ENV['MONGO_RUBY_DRIVER_PORT'] || MongoClient::DEFAULT_PORT
puts "Connecting to #{host}:#{port}"
db = MongoClient.new(host, port).db('images')
grid = Grid.new(db)

@@files_collection = db.collection("fs.files") 

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/model")
require 'user'

def file_download(filename)
	# This helper function is used to download files with and without extensions
	# Look in GridFS for the given filename, sorting by the uploadDate
	cursor = @@files_collection.find({"filename" => filename}, {:sort => ["uploadDate", :desc]})
	if cursor.count > 1
		response_string = "There are #{cursor.count} files that have the name: #{filename}.<br> They are listed below along with the dates on which they were uploaded. Click any of the links to download the file.<br>"
		cursor.each do |file_item|
			response_string = response_string + "<a href=\"#{request.base_url}/download/id/#{file_item["_id"].to_s}\">Date: #{file_item["uploadDate"].to_s} &nbsp;&nbsp; Filename: #{filename}</a><br>"
		end
	else
		# Since there is only one file, redirect so that they get the download.
		redirect "/download/id/#{cursor.first["_id"].to_s}"
	end
	response_string
end

configure do
	enable :sessions, :logging
	set :session_secret, '3229450eae59f7eb02a3d60e995e19453d4bb5a3'
	set :environment, :development
	set :root, File.dirname(__FILE__)
	set :server, %w[thin]
	set :bind, '127.0.0.1'
	set :port, '4567'
	set :app_file, __FILE__
	set :public_folder, Proc.new { File.join(root, "static") }
	set :views, Proc.new { File.join(root, "views") }
	set :erb, :layout_engine => :erb, :layout => :'layouts/default', :pretty => #{settings.environment}
	class ::Logger; alias_method :write, :<<; end
	logfile = File.new("#{settings.root}/log/#{settings.environment}.log", 'a+')
	$stdout.reopen(logfile)
	$stderr.reopen(logfile)
	$stderr.sync = true
	$stdout.sync = true
	database_config = YAML.load_file("config/database.yml")
	ActiveRecord::Base.establish_connection(database_config)
end

get "/" do
	erb :index
end

get "/signup" do
	@user = Users.new
	erb :signup
end

get "/login" do
	erb :login
end

get "/logout" do
	session[:user] = nil
	redirect "/"
end

get "/upload" do
	#@images = Image.all
	erb :upload
end

get "/images/:id" do |id|
	@image = Image.where(:id => id).first()
	erb :view
end

post "/signup" do
	@user = Users.new(params[:user])
	if @user.save
	#	session[:user] = Users.authenticate(@user.name, @user.passwd)
		session[:user] = params[:user][:name]
		redirect "/"
	else
		flash[:error] = "Format of form was wrong!"
		redirect "/signup"
	end
end

post "/login" do
	if session[:user] = Users.authenticate(params[:user][:name], params[:user][:passwd])
		session[:user] = params[:user][:name]
		redirect "/", flash[:notice] => 'Login Success'
	else 
		flash[:error] = "User or Password was wrong!"
		redirect "/login"
	end
end

post "/upload" do
	@image = grid.put(params[:image][:tempfile].read)
	#@image = Image.create(:image => params[:image][:uploaded_photo])
	#@image.file_name = params[:image][:name]
	return "Image Successfully upload! id=#{$id}"
	#redirect '/'
end

get "/most_recent_upload" do
	# Get the file handle from gridfs
	file = grid.get($id)
	# Set the content type to generic
	content_type 'binary/octet-stream'
	#Push the file at the browser
	attachment "#{file.filename}"
	response.write file.read
end

get '/download/:filename' do |filename|
	  file_download(filename)
end

# Get a file by a specific file id
get '/download/id/:file_id' do |file_id|
	file = grid.get(BSON::ObjectId("#{file_id}"))
	content_type 'binary/octet-stream'
	#Push the file at the browser
	attachment "#{file.filename}"
	response.write file.read
end

__END__

