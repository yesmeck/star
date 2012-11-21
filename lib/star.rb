# encoding: utf-8

require "faraday_middleware"
require "taglib"
require "cgi/cookie"

module Star
  PLAYLIST_URL = "http://douban.fm/j/mine/playlist"

  def self.connection(url, parse = false)
    Faraday.new url do |conn|
      conn.request :url_encoded
      if parse
        conn.use FaradayMiddleware::Mashify
        conn.use FaradayMiddleware::ParseJson
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def self.request(cookies)
    cookie = []
    cookies.each do |key, value|
      cookie << "#{key}=\"#{value}\""
    end

    res = self.connection(PLAYLIST_URL, true).get do |req|
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

  def self.download(song)
    res = self.connection(song.url).get
    File.open(song.path, "wb") do |f|
      f.write(res.body)
    end
    self.write_tags(song)
  end

  def self.write_tags(song)
    TagLib::FileRef.open(song.path) do |fileref|
      fileref.tag.title = song.title
      fileref.tag.artist = song.artist
      fileref.tag.album = song.albumtitle
      fileref.tag.year = song.public_time.to_i
      fileref.save
    end
  end

  def self.captcha
    res = connection("http://douban.fm/j/new_captcha").get
    $captcha_id = res.body.gsub!('"', '')
    "http://douban.fm/misc/captcha?size=m&id=#{$captcha_id}"
  end

  def self.login(username, password, captcha)
    res = connection("http://douban.fm/j/login").post do |req|
      req.body = {
        :source => "radio",
        :alias => username,
        :form_password => password,
        :captcha_solution => captcha,
        :captcha_id => $captcha_id,
        :task => "sync_channel_list"
      }
    end

    cookie = CGI::Cookie::parse(res.env[:response_headers]["set-cookie"])
    {
      "dbcl2" => cookie["dbcl2"][0].gsub!(/\"/, "").gsub(/ /, "+")
    }
  end
end

