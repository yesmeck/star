# encoding: utf-8

lib = File.expand_path(File.dirname(__FILE__) + '/lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib) && !$LOAD_PATH.include?(lib)

require "star"

$downloaded_song = []

star = Star.new

Shoes.app do
  stack do
    para "Username:"
    username = edit_line
    para "Password:"
    password = edit_line
    para "Captcha:"
    image download_captcha(star.captcha)
    captcha = para = edit_line
    para "How many songs do you want?"
    $download_count = edit_line
    para = "Download to?"
    save_path = edit_line

    button "Login" do
      login = star.login(username.text, password.text, captcha.text)
      if !login
        p star.login_error
      end
      while !download_enough?
        star.songs.each do |song|
          if !$downloaded_song.include?(song.sid) && !download_enough?
            puts "Downloading 《#{song.title} - #{song.artist}》..."
            song.save_to(save_path.text)
            $downloaded_song << song.sid
          end
        end
      end

      puts "Downloaded #{$downloaded_song.count} songs."
    end
  end
end

def download_captcha(url)
  tmp_file = "/tmp/star-captcha.jpg"
  res = Star.connection(url).get
  File.open(tmp_file, "wb") do |f|
    f.write res.body
  end
  tmp_file
end

def download_enough?
  $downloaded_song.count >= $download_count.text.to_i
end
