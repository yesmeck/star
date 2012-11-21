# encoding: utf-8

require "spec_helper"

describe Star do
  let(:star) { Star.new }

  describe "#captcha" do
    it "return a captcha link" do
      stub_get("/j/new_captcha").to_return(:body => '"vj6Q90GyHSFG5Oi5zjgfHo7N"')
      star.captcha.should == "http://douban.fm/misc/captcha?size=m&id=vj6Q90GyHSFG5Oi5zjgfHo7N"
    end
  end

  describe "#login" do
    context "with wrong password given" do
      it "should return false and set error message" do
        stub_post("/j/login").
          with(
            :content => {
              :source => "radio",
              :alias => "wrong@username.com",
              :form_password => "wrongpassword",
              :captcha_solution => "wrongcaptcha",
              :captcha_id => "fakecaptchaid",
              :task => "sync_channel_list"
            }
          ).
          to_return(:body => '{"err_no":1013,"r":1,"err_msg":"帐号和密码不匹配"}')

        star.instance_variable_set("@captcha_id", "fakecaptchaid")
        star.login("wrong@username.com", "wrongpassword", "wrongcaptcha").should == false
        star.login_error.should == "帐号和密码不匹配"
      end
    end

    context "with right login info given" do
      it "should return true and set cookie" do
        stub_post("/j/login").
          with(
            :content => {
              :source => "radio",
              :alias => "right@username.com",
              :form_password => "right",
              :captcha_solution => "rightcaptcha",
              :captcha_id => "fakecaptchaid",
              :task => "sync_channel_list"
            }
          ).
          to_return(
            :body => "{}",
            :headers => {
              "Set-Cookie" => 'dbcl2="1407404:WcB62LEzS+o"; path=/; domain=.douban.fm; httponly'
            }
          )

        star.instance_variable_set("@captcha_id", "fakecaptchaid")
        star.login("right@username.com", "rightpassword", "rightcaptcha").should == true
        star.login_error.should == nil
        star.instance_eval{ @cookie }.should == {
          "dbcl2" => "1407404:WcB62LEzS+o"
        }
      end
    end
  end

  describe "#songs" do
    it "should return a song list" do
      stub_get("/j/mine/playlist").
        with(
          :query => {
            :type => "s",
            :sid => "1496963",
            :pt => "3.1",
            :channel => "-3",
            :from => "mainsite",
            :r => "567fd78b89"
          },
          :headers => {
            "Cookie" => 'dbcl2="1407404:WcB62LEzS+o"'
          }
        ).to_return(:body => fixture("songs.json"))
        star.instance_variable_set("@cookie", { "dbcl2" => "1407404:WcB62LEzS+o" })
        star.songs.first.title.should == "Creep"
    end
  end
end
