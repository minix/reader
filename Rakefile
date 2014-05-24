require 'active_record'
require 'logger'
require 'yaml'

task :environment do
	 env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
	 ActiveRecord::Base.establish_connection(YAML::load_file('config/database.yml'))
	 ActiveRecord::Base.logger = Logger.new(File.open('log/database.log', 'a+'))
end

namespace :db do
	desc "Create the database"
	task(:create => :environment) do
	  env = ENV["RACK_ENV"] ? ENV["RACK_ENV"] : "development"
	  config = YAML::load_file('config/database.yml')
	  ActiveRecord::Base.establish_connection(config.merge('database' => nil))
	  ActiveRecord::Base.connection.create_database config['database']
	end

	task :default => :migrate

	desc "Migrate the database"
	task(:migrate => :environment) do
		ActiveRecord::Migrator.migrate('db/migrate', ENV['VERSION'] ? ENV['VERSION'].to_i : nil)
	end
end


