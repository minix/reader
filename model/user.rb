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
