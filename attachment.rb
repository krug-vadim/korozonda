#!/usr/bin/ruby
# encoding: utf-8

# такие крутые выходные шиzа

# 2013-04-29 00:39

require 'net/http'
require 'uri'

require 'zaru'

class Attachment
	attr_reader :post_dir

	def initialize(post_dir)
		@post_dir = post_dir
	end

	def download_file(url, filename)
		filename = filename[0 .. 254 ] if filename.size >= 255
		File.open(filename, 'wb') { |f| f.puts Net::HTTP.get(URI.parse(url)) }
	end
end

class PhotoAttachment < Attachment
	attr_reader :raw

	def initialize(raw, post_dir)
		@raw = raw
		super(post_dir)
	end

	def pid
		@raw['pid']
	end

	def src_big
		big = 'src_big'

		@raw.keys.select{ |key| key =~ /^src\_([x]+)big$/ }.each do |key|
			big = key if key.size > big.size
		end

		@raw[big]
	end

	def save
		puts "[i] downloading #{src_big}..."
		download_file(src_big, "#{post_dir}/#{pid}.jpg")
		puts "[i] downloaded"
	end
end

class UrlAttachment < Attachment
	attr_reader :raw

	def initialize(raw)
		@raw = raw
	end

	def save
	end
end

class AudioAttachment < Attachment
	attr_reader :raw

	def initialize(app, raw, post_dir)
		@raw = raw
		@app = app
		@info = []
		super(post_dir)
	end

	def owner_id
		@raw['owner_id']
	end

	def aid
		@raw['aid']
	end

	def get_info
		@info = @app.audio.audio.getById(audios: "#{owner_id}_#{aid}")[0]
		return (@info != [])
	end

	def url
		@info['url']
	end

	def artist
		@info['artist'].sub(/[\/]/,'!')
	end

	def title
		@info['title'].sub(/[\/]/,'|')
	end

	def save
		return if !get_info

		track_name = "#{artist} - #{title}.mp3"
		track_name = Zaru.sanitize!(track_name)

		return if track_name.empty?

		puts "[i] downloading #{track_name}: #{url}..."
		download_file(url, "#{post_dir}/#{track_name}")
		puts "[i] downloaded"
	end
end

class AttachmentFactory
	def self.create(app, typename, info, post_dir)
		case typename
		when 'photo'
			return PhotoAttachment::new(info, post_dir)
		when 'posted_photo'
			return PhotoAttachment::new(info, post_dir)
		when 'audio'
			return AudioAttachment::new(app, info, post_dir)
		else
			#raise "unknown attachment type: #{typename}"
		end
	end
end
