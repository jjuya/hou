class BoardsController < ApplicationController

  before_action :set_board, only: [:show, :edit, :update, :destroy]
  # before_action :user_check, only: [:show, :edit, :update, :destroy]

  def index
    @board = Board.new
  end

  def show
    @lists = @board.lists
    @list = List.new()
    @bookmark = Bookmark.new()
  end

  def new
    @board = Board.new
  end

  def create
    @board = Board.create(board_params)

    List.create(
      title: "No title",
      board_id: @board.id
    )

    render :json => @board
  end

  def edit
  end

  def update
    @board.update(board_params)

    respond_to do |format|
      format.html { redirect_to "root" }
      format.js {}
    end
  end

  def destroy
    @board.destroy
    redirect_to root_path
  end

  private
  def set_board
    @board = Board.find(params[:id])

    user_check
  end

  def board_params
    params.require(:board).permit(:title, :user_id)
  end

  def user_check
    if current_user.id != @board.user_id
      redirect_to :root
    end
  end

end
