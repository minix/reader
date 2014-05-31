require 'yaml'

@config = YAML.load_file("config/mongodb.yml") #ruby app.rb
@environment = @config["environment"]

@db_host = @config[@environment]["host"]
@db_port = @config[@environment]["port"]
@db_database = @config[@environment]["database"]

MongoMapper.connection = Mongo::Connection.new(@db_host,@db_port)
MongoMapper.database = @db_database
MongoMapper.connection.connect
