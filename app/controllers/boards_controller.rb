class BoardsController < ApplicationController
  before_action :set_board, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
    @lists = @board.lists
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def set_board
    @board = Board.find(params[:id])
  end

  def board_params
  	params.require(:board).permit(:title, :user_id)
  end
end
