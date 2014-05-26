class CreateContents < ActiveRecord::Migration
	def self.up
		create_table :content do |t|
			t.string :title
			t.string :site_name
			t.string :issue_time
			t.text   :content
			t.integer :collect_id

			t.timestamps
		end

		def self.down
			drop table :content
		end
	end
end
