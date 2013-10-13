class TagController < ApplicationController
	
  def index
  	@posts = Post.tagged_with(params[:tag])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts }
    end
  end
end
