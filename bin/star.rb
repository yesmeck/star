#!/usr/bin/env ruby
# encoding: utf-8

require "faraday_middleware"
require "taglib"

PLAYLIST_URL = "http://douban.fm/j/mine/playlist"
DOWNLOAD_DIR = "/home/meck/Music/star"

def connection(url, parse = false)
  Faraday.new url do |conn|
    conn.request :url_encoded
    if parse
      conn.use FaradayMiddleware::Mashify
      conn.use FaradayMiddleware::ParseJson
    end
    conn.adapter Faraday.default_adapter
  end
end

def request(cookies)
  cookie = []
  cookies.each do |key, value|
    cookie << "#{key}=\"#{value}\""
  end

  res = connection(PLAYLIST_URL, true).get do |req|
    req.headers['Cookie'] = cookie.join("; ")
    req.params = {
      :type => "s",
      :sid => "1496963",
      :pt => "3.1",
      :channel => "-3",
      :from => "mainsite",
      :r => "567fd78b89"
    }
  end

  res.body.song
end

def download(song)
  res = connection(song.url).get
  File.open(song.path, "wb") do |f|
    f.write(res.body)
  end
  write_tags(song)
end

def write_tags(song)
  TagLib::FileRef.open(song.path) do |fileref|
    fileref.tag.title = song.title
    fileref.tag.artist = song.artist
    fileref.tag.album = song.albumtitle
    fileref.tag.year = song.public_time.to_i
    fileref.save
  end
end

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
  request(cookie).each do |song|
    if !downloaded_song.include?(song.sid)
      puts "Downloading 《#{song.title} - #{song.artist}》..."
      song.path = "#{DOWNLOAD_DIR}/#{song.title}.mp3";
      download song
      downloaded_song << song.sid
    end
  end
end

puts "Downloaded #{downloaded_song.count} songs."
