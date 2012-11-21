#!/usr/bin/env ruby
# encoding: utf-8

require "star"

@downloaded_song = []

star = Star.new

puts "Username:"
username = gets.chomp
puts "Password:"
password = gets.chomp
puts "Captcha:"
puts star.captcha
captcha = gets.chomp
puts "How many songs do you want?"
@download_count = gets.chomp
puts "Download to?"
save_path = gets.chomp

star.login(username, password, captcha)


def download_enough?
  @downloaded_song.count >= @download_count.to_i
end

while !download_enough?
  star.songs.each do |song|
    if !@downloaded_song.include?(song.sid) && !download_enough?
      puts "Downloading 《#{song.title} - #{song.artist}》..."
      song.save_to(save_path)
      @downloaded_song << song.sid
    end
  end
end

puts "Downloaded #{@downloaded_song.count} songs."

