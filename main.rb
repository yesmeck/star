# encoding: utf-8

Shoes.app do
  stack do
    para "Username:"
    username = edit_line
    para "Password:"
    password = edit_line

    button "Login" do
      para username.text
      para password.text
    end
  end
end
