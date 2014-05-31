class Image
	include MongoMapper::Document

	key :_id, ObjectId , :required => true
	key :name, String, :required => false
	key :description, String, :required => false

	key :historys, Array, :required => false
	key :is_deleted, Boolean, :required => false
	key :created, Time, :required => false

	key :created_by, ObjectId, :required => false
	key :modified, Time, :required => false
	key :modified_by, ObjectId, :required => false

	key :current, ObjectId, :required => false
	#many :books
end
