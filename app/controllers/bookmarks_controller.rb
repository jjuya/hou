class BookmarksController < ApplicationController

  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
    @board = Board.find(@bookmark.board_id)
  end

  def new
    @board_id = params[:board_id]
    @lists = Board.find(@board_id).lists
    @bookmark = Bookmark.new()
  end

  def create
    bookmark = Bookmark.create(bookmark_params)
    list = List.find(bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  def edit
    board = List.find(@bookmark.list_id).board
    @lists = board.lists
  end

  def update
    @bookmark.update(bookmark_params)

    list = List.find(bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  def destroy
    @bookmark.destroy
    
    list = List.find(bookmark.list_id)

    redirect_to board_path(list.board_id)
  end

  private
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
  	params.require(:bookmark).permit(:title, :url, :list_id, :tag_1, :tag_2, :tag_3)
  end

end
