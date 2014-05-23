require 'sinatra'
require 'active_record'
require 'digest/sha1'
require 'logger'

ActiveRecord::Base.establish_connection(
	:adapter  => "mysql2",
	:host     => "localhost",
	:username => "minix",
	:password 	=> "M-gtuiw",
	:database => "site"
)

#ActiveRecord::Migration.create_table :users do |t|
#	t.string :name
#	t.string :hash_passwd
#	t.string :passwd
#	t.string :salt
#	t.string :email
#end

class Users < ActiveRecord::Base
	EMAIL_REGEX = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i
	validates_presence_of :name, :passwd, message: "Name or Password don't empty! "
	validates_confirmation_of :passwd, message: "should match confirmation"
	validates_uniqueness_of :name, message: "Name exist !"

	def passwd
		@passwd
	end

	def passwd=(passwd)
		@passwd = passwd
		self.salt = Users.random_string(10) if !self.salt?
		self.hash_passwd = Users.encrypt(@passwd, self.salt)
	end

	def self.authenticate(name, passwd)
		#u = Users.find_by name: 'name'
		u = Users.find_by_name(name)
		return nil if u.nil?
		return u if Users.encrypt(passwd, u.salt) == u.hash_passwd
		nil
	end

	def send_new_passwd
		new_passwork = Users.random_string(10)
		self.passwd = self.passwd_confirmation = new_passwd
		self.save
		#Notifications.deliver_forgot_passwd(self.email, self.name, new_passwd)
	end

	protected

	def self.encrypt(passwd, salt)
		Digest::SHA1.hexdigest(passwd+salt)
	end

	def self.random_string(len)
		chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
		newpasswd = ""
		1.upto(len) { |i| newpasswd << chars[rand(chars.size-1)] }
		return newpasswd
	end
end

enable :sessions
set :session_secret, '3229450eae59f7eb02a3d60e995e19453d4bb5a3'
set :environment, :development
set :root, File.dirname(__FILE__)
set :server, %w[thin]
set :bind, '127.0.0.1'
set :port, '4567'
set :app_file, __FILE__
set :public_folder, Proc.new { File.join(root, "static") }
set :views, Proc.new { File.join(root, "views") }
logger = ::Logger.new("log/development.log")
logger.level = ::Logger::DEBUG


def require_logged_in
	redirect('/login') unless is _authenticated?
end

def is_authenticated?
	return !!session[:user]
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

post "/signup" do
	@user = Users.new(params[:user])
	if @user.save
	#	session[:user] = Users.authenticate(@user.name, @user.passwd)
		session[:user] = params[:user][:name]
		redirect "/"
	else
		'Signup Unsuccessful'
	end
end

post "/login" do
	if session[:user] = Users.authenticate(params[:user][:name], params[:user][:passwd])
		session[:user] = params[:user][:name]
		redirect "/"
	else 
		erb :error
	end
end

get "/logout" do
	session[:user] = nil
	redirect "/"
end

__END__

@@layout
<!DOCTYPE html>
<html>
<head>
<title>Photo</title>
</head>
<body>
<%= yield %>
</body>
</html>

