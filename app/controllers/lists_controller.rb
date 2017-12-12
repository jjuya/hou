class ListsController < ApplicationController

  before_action :set_list, only: [:show, :edit, :update, :destroy]

  def index
  end

  def show
  end

  def new
    @board_id = params[:board_id]

    @list = List.new()
  end

  def create
    @list = List.create(list_params)

    redirect_to board_path(list_params[:board_id])
  end

  def edit
  end

  def update
    @list.update(list_params)

    redirect_to board_path(list_params[:board_id])
  end

  def destroy
    noTitle = List.find_by(title: "No title", board_id: @list.board_id)

    @list.bookmarks.each do |b|
      b.update(list_id: noTitle.id)
    end

    @list.destroy

    redirect_to board_path(@list.board_id)
  end

  private
  def set_list
    @list = List.find(params[:id])
  end

  def list_params
  	params.require(:list).permit(:title, :board_id)
  end
end
