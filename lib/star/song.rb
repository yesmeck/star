# encoding: utf-8

class Star
  class Song
    attr_accessor :sid, :album, :title, :artist, :url
    attr_reader :save_path, :year

    def initialize(attrs)
      attrs.each do |key, value|
        send("#{key}=", value)
      end
    end

    def save_to(path)
      # remove tailling slash
      @save_path = "#{path.chomp("/")}/#{self.title}.mp3"

      res = Star.connection(@url).get

      File.open(@save_path, "wb") do |f|
        f.write(res.body)
      end
      write_tags
    end

    def write_tags
      TagLib::FileRef.open(@save_path) do |fileref|
        fileref.tag.title = @title
        fileref.tag.artist = @artist
        fileref.tag.album = @album
        fileref.tag.year = @year
        fileref.save
      end
    end

    def year=(year)
      @year = year.to_i
    end
  end
end
