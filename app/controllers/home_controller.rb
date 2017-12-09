class HomeController < ApplicationController
	before_action :set_board, only: [:show, :edit, :update, :destroy]

	def index
		@board = Board.new
	end

	private
	def set_board
		@board = Board.find(params[:id])

		user_check
	end

	def user_check
		if current_user.id != @board.user_id
			redirect_to :root
		end
	end
end
