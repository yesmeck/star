#!/usr/bin/env ruby
# encoding: utf-8

require "star"

DOWNLOAD_DIR = "/home/meck/Music/star"

downloaded_song = []
cookie = {}

puts "Input cookie:"
puts "dbcl2:"
cookie["dbcl2"] = gets.chomp
puts "bid:"
cookie["bid"] = gets.chomp
puts "How many songs do you want?"
download_count = gets.chomp


while downloaded_song.count < download_count.to_i
  Star.request(cookie).each do |song|
    if !downloaded_song.include?(song.sid)
      puts "Downloading 《#{song.title} - #{song.artist}》..."
      song.path = "#{DOWNLOAD_DIR}/#{song.title.gsub(/\//, '|')}.mp3";
      Star.download song
      downloaded_song << song.sid
    end
  end
end

puts "Downloaded #{downloaded_song.count} songs."
