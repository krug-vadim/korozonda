#!/usr/bin/ruby
# encoding: utf-8

# шифрация на работе mode шиza

# 2013-03-04 17:23

# save_post_text(post)
# save_post_attachments(post)
# save_post_comments(post)

=begin
id - идентификатор записи на стене пользователя
to_id - идентификатор владельца записи
from_id - идентификатор пользователя, создавшего запись
date - время публикации записи в формате unixtime
text - текст записи
comments - содержит информацию о количестве комментариев к записи. Более подробная информация представлена на странице Описание поля comments
likes - содержит информацию о числе людей, которым понравилась данная запись. Более подробная информация представлена на странице Описание поля likes
reposts - содержит информацию о числе людей, которые скопировали данную запись на свою страницу. Более подробная информация представлена на странице Описание поля reposts
attachments - содержит массив объектов, которые присоединены к текущей записи (фотографии, ссылки и т.п.). Более подробная информация представлена на странице Описание поля attachments
geo - если в записи содержится информация о местоположении, то она будет представлена в данном поле. Более подробная информация представлена на странице Описание поля geo
signer_id - если запись была опубликована от имени группы и подписана пользователем, то в поле содержится идентификатор её автора
copy_owner_id - если запись является копией записи с чужой стены, то в поле содержится идентификатор владельца стены у которого была скопирована запись
copy_post_id - если запись является копией записи с чужой стены, то в поле содержится идентфикатор скопированной записи на стене ее владельца
copy_text - если запись является копией записи с чужой стены и при её копировании был добавлен комментарий, его текст содержится в данном поле
=end

require_relative 'attachment'

class Post
	attr_reader :comments
	attr_reader :attachments

	def initialize(app, raw)
		@raw = raw
		@app = app
		@attachments = get_attachments
	end

	def id
		@raw['id']
	end

	def date
		@raw['date']
	end

	def text
		@raw['text']
	end

	def get_attachments
		return [] if !@raw.include?('attachments')
		return [] if @raw['attachments'].empty?
		@raw['attachments'].map do |attachment|
			AttachmentFactory::create(
				@app,
				attachment['type'],
				attachment[attachment['type']],
				post_dir)
		end
	end

	def post_dir
		"%05d" % id
	end

	def raw_path
		"#{post_dir}/raw"
	end

	def exists?
		return false if not Dir::exist?(post_dir)
		return false if not File::exist?(raw_path)

		puts "raw exists"

		old_raw = File::open(raw_path).read

		return false if @raw != old_raw

		true
	end

	def save_raw
		Dir::mkdir(post_dir) if not Dir::exist?(post_dir)

		File::new(raw_path, 'w').write(@raw)
	end

	def save_comments
		return if @raw['comments']['count'].times <= 0
	end

	def save_attachments
		attachments.each { |attachment| attachment.save if attachment }
	end

	def save
		return if exists?

		save_comments
		save_attachments
		save_raw
	end
end
