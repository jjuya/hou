class BoardsController < ApplicationController

  before_action :set_board, only: [:show, :edit, :update, :destroy]
  # before_action :user_check, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to root_path
  end

  def show
    @lists = @board.lists
    @list = List.new()
    @bookmark = Bookmark.new()
  end

  def new
    redirect_to root_path
  end

  def create
    board = Board.create(board_params)
    # puts board.errors.inspect if board.errors

    if board.save
      List.create(
        title: "No title",
        board_id: board.id
      )

      render :json => board
    else
      flash[:toastr] = { "error" => "Error: Not Create Board" }
      redirect_to root_path
    end
  end

  def edit
  end

  def update
    @board.update(board_params)

    if @board.save
      respond_to do |format|
        format.html { redirect_to "root" }
        format.js {}
      end
    else
      flash[:toastr] = { "error" => "Error: Not Update Board Title" }
      redirect_to board_path(@board)
    end
  end

  def destroy
    @board.destroy

    if @board.save
      redirect_to root_path
    else
      flash[:toastr] = { "error" => "Error: Not Destroy Board" }
      redirect_to root_path
    end
  end

  private
  def set_board
    @board = Board.find(params[:id])

    user_check
  end

  def board_params
    params.require(:board).permit(:title, :user_id, :starred)
  end

  def user_check
    if current_user.id != @board.user_id
      redirect_to :root
    end
  end

end
