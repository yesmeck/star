# encoding: utf-8

describe Star::Song do
  let(:song) do
    Star::Song.new(
      :year => 2008,
      :album => "The Best of Radio...",
      :title => "Creep",
      :artist => "Radiohead",
      :url => "http://mr4.douban.com/201211212227/c54d04e1dd22cfc82fb990ccdf7d4db0/view/song/small/p71834.mp3"
    )
  end

  describe "#save_to" do
    context "with a path given" do
      it "should save the song to the path" do
        stub_get(song.url).to_return(:body => fixture("Creep.mp3"))
        song.save_to("/tmp")
        File.exists?(song.save_path).should be_true
      end
    end
  end
end
