#!/usr/bin/ruby
# encoding: utf-8

# потыкал веточкой

# 2013-03-13 13:41

require_relative 'attachment'

class Comment
	attr_reader :post_dir
	attr_reader :attachments

	def initialize(app, raw, post_dir)
		@raw = raw
		@app = app
		@post_dir = post_dir

		@attachments = get_attachments
	end

	def cid
		@raw['cid']
	end

	def uid
		@raw['uid']
	end

	def date
		@raw['date']
	end

	def text
		@raw['text']
	end

	def get_attachments
		return [] if !@raw.include?('attachments')
		AttachmentFactory.get_attachments(@app, @raw['attachments'], post_dir)
	end

	def raw_path
		"#{post_dir}/#{cid}.comment"
	end

	def exists?
		return false if not Dir::exist?(post_dir)
		return false if not File::exist?(raw_path)

		old_raw = File::open(raw_path).read

		return false if @raw != old_raw

		true
	end

	def save_raw
		Dir::mkdir(post_dir) if not Dir::exist?(post_dir)

		File::new(raw_path, 'w').write(@raw)
	end

	def save_attachments
		attachments.each { |attachment| attachment.save if attachment }
	end

	def save
		return if exists?

		save_attachments
		save_raw
	end
end
