require 'mongoid'
#require 'mini_magick'
#include MiniMagick

class Image
	include Mongoid::Document

	field :name, type: String
	field :types, type: Array
	field :image, type: String



end
#	attachment :image
#
#	validates_format_of :content_type,
#		with: /^image/,
#		message: "--- Must upload photo"
#
#	#def uploaded_photo=(photo_field)
#	#	self.name	= base_part_of(photo_field.original_filename)
#	#	self.content_type	= photo_field.content_type.chomp
#	#	img = MiniMagick::Image.read(photo_field.read)
#	#	unless img.nil?
#	#		if self.content_type.chomp == 'png' or self.content_type.chomp == 'gif'
#	#			img.convert("jpg")
#	#		end
#	#		img_original = img_large = img_thumbnail = img
#	#		img_original.strip
#	#		img_original.quality("75%")
#	#		self.original = img_original.to_blob
#	#	end
#	#end
#
#	def base_part_of(file_name)
#		File.basename(file_name).gsub(/[^\w._-]/, '')
#	end
#	def string_to_binary(value)
#		return "data:#{file_type(value)};base64," + Base64.encode64(value)
#	end
#
#	def original_filename
#		unless defined? @original_filename
#			@original_filename =
#				unless original_path.blank?
#					if original_path =~ /^(?:.*[:\\\/])?(.*)/m
#						$1
#					else
#						File.basename original_path
#					end
#				end
#		end
#		@original_filename
#	end
#
#	def content_type
#		headers["Content-Type"]
#	end
#
#	private
#	def crop_image(image, width, height)
#		image.resize(width+'x'+height).strip
#		image.quality("75%")
#		self.original = image.to_blob
#	end
#end
