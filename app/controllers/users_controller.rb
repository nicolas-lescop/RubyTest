class UserController < ApplicationController
  before_filter :authenticate_user!

  def index
    @posts = current_user.posts.all
  end
end