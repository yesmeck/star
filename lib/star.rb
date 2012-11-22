# encoding: utf-8

require "faraday_middleware"
require "taglib"
require "cgi/cookie"
require "star/song"

class Star
  def self.full_url(path)
    path.sub!(/^\//, "")
    "http://douban.fm/#{path}"
  end

  def self.connection(path, parse = false)
    if path.start_with?("http")
      url = path
    else
      url = Star.full_url(path)
    end
    Faraday.new url do |conn|
      conn.request :url_encoded
      if parse
        conn.use FaradayMiddleware::Mashify
        conn.use FaradayMiddleware::ParseJson
      end
      conn.adapter Faraday.default_adapter
    end
  end

  def songs()
    cookie = []
    @cookie.each do |key, value|
      cookie << "#{key}=\"#{value}\""
    end

    res = Star.connection("/j/mine/playlist", true).get do |req|
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

    songs = []

    res.body.song.each do |song|
      star_song = Star::Song.new(
        :sid => song.sid,
        :year => song.public_time,
        :album => song.albumtitle,
        :title => song.title,
        :artist => song.artist,
        :url => song.url
      )
      songs << star_song
    end

    songs
  end

  def captcha
    res = Star.connection("/j/new_captcha").get
    @captcha_id = res.body.gsub!('"', '')
    Star.full_url("/misc/captcha?size=m&id=#{@captcha_id}")
  end

  def login(username, password, captcha)
    # reset login error
    @login_error = nil

    res = Star.connection("/j/login", true).post do |req|
      req.body = {
        :source => "radio",
        :alias => username,
        :form_password => password,
        :captcha_solution => captcha,
        :captcha_id => @captcha_id,
        :task => "sync_channel_list"
      }
    end

    if !res.body.err_msg.nil?
      @login_error = res.body.err_msg
      return false
    end

    set_cookie(res.headers["set-cookie"])

    true
  end

  def set_cookie(cookie)
    cookie = CGI::Cookie::parse(cookie)
    @cookie = {
      "dbcl2" => cookie["dbcl2"][0].gsub!(/\"/, "").gsub(/ /, "+")
    }
  end

  def login_error
    @login_error
  end
end

