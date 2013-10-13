class UserController < ApplicationController

  def index
    @user = User.find_by_username(params[:username])
    @posts = @user.posts

    respond_to do |format|
      format.html
      format.json { render json: @posts}
    end	
  end
end
