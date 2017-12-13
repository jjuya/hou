class BookmarksController < ApplicationController

  before_action :set_bookmark, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to root_path
  end

  def show
    redirect_to root_path
  end

  def new
    redirect_to root_path
  end

  def create
    bookmark = Bookmark.create(bookmark_params)
    list = List.find(bookmark.list_id)

    if bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:error] = "Error: Not Bookmark Bookmark"
      redirect_to board_path(list.board_id)
    end
  end

  def edit
    redirect_to root_path
  end

  def update
    @bookmark.update(bookmark_params)

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:error] = "Error: Not Update Bookmark"
      redirect_to board_path(list.board_id)
    end
  end

  def destroy
    @bookmark.destroy

    list = List.find(@bookmark.list_id)

    if @bookmark.save
      redirect_to board_path(list.board_id)
    else
      flash[:error] = "Error: Not Destroy Bookmark"
      redirect_to board_path(list.board_id)
    end
  end

  private
  def set_bookmark
    @bookmark = Bookmark.find(params[:id])
  end

  def bookmark_params
  	params.require(:bookmark).permit(:title, :url, :description, :list_id, :tag_1, :tag_2, :tag_3, :rating)
  end

end
