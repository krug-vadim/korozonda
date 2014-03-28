#!/usr/bin/ruby
# encoding: utf-8

# вечно пьянный шиzа

# вк даунлоаудер
# 2013-03-01 02:24

# https://oauth.vk.com/authorize?
#  client_id=APP_ID&
#  scope=SETTINGS&
#  redirect_uri=REDIRECT_URI&
#  display=DISPLAY&
#  response_type=token

# https://oauth.vk.com/authorize?client_id=3461442&scope=wall&

def url(id, scope, redirect, display)
	str = []
	str << "client_id=#{id}"
	str << "scope=#{scope}&"
	str << "redirect_uri=#{redirect}&"
	str << "display=#{display}&"
	str << "response_type=token"

	'https://oauth.vk.com/authorize?' + str.join('&')
end

require 'vk-ruby'
require 'yaml'

require_relative 'post'

$settings = YAML.load( File.open('settings.yml') )
STEP = 100

=begin
notify	Пользователь разрешил отправлять ему уведомления.
friends	Доступ к друзьям.
photos	Доступ к фотографиям.
audio	Доступ к аудиозаписям.
video	Доступ к видеозаписям.
docs	Доступ к документам.
notes	Доступ заметкам пользователя.
pages	Доступ к wiki-страницам.
status	Доступ к статусу пользователя.
offers	Доступ к предложениям (устаревшие методы).
questions	Доступ к вопросам (устаревшие методы).
wall
=end

module VK
	APP_ID       = $settings['app_id']
	APP_SECRET   = $settings['app_secret']
	ACCESS_TOKEN = $settings['access_token']
end

if ( ARGV.size > 0 )
	puts url(VK::APP_ID, 'wall,audio', 'http://oauth.vk.com/blank.html', 'page')
	raise
end

app = VK::Application.new

Dir::chdir('./posts')

total, = app.wall.get(count: 1, filter: 'all')

puts total

(0 .. total).step(STEP).each do |offset|
	puts offset

	posts = app.wall.get(offset: offset, count: STEP, filter: 'all')
	posts = posts[1..-1]

	posts.each do |raw|
		post = Post::new(app, raw)
		post.save
		sleep(0.5)
	end
end
