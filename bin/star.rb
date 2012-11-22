#!/usr/bin/env ruby
# encoding: utf-8

lib = File.expand_path(File.dirname(__FILE__) + '/../lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require "star"
require "highline/import"

@downloaded_song = []

star = Star.new

begin
  if !star.login_error.nil?
    puts star.login_error
  end
  username = ask("Username: ")
  password = ask("Password: ") { |q| q.echo = "x" }
  puts star.captcha
  captcha = ask("Captcha: ")
end while not star.login(username, password, captcha)

@download_count = ask("How many songs do you want? ")
save_path = ask("Download to? ")

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

