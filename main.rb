require 'sinatra'
require 'active_record'
require 'digest/sha1'
require 'sinatra/flash'
require 'logger'
require 'yaml'
require 'mongo_mapper'

require File.join(File.dirname(__FILE__),'config/db')
require File.join(File.dirname(__FILE__),'model/mongodb')

$LOAD_PATH.unshift(File.dirname(__FILE__) + "/model")
require 'user'
require 'mongodb'

before do
	@db = Mongo::Connection.new.db("image")
	@grid_fs = Mongo::Grid.new(@db)
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
	erb :upload
end

get "/view" do
	@image = Image.find
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
	image = params[:images][:image][:tempfile].read
	@image = Image.create(
		:_id => BSON::ObjectId.new,
		:current => @grid_fs.put(
			image,
			:is_deleted => false
		)
	)
	redirect "/view"
end

__END__

