class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  before_action :authenticate_user!
  protect_from_forgery with: :exception

  before_action :set_boards

  def set_boards
  	if current_user
  		@boards = current_user.boards
  	end
  end
end
