class ListsController < ApplicationController

  before_action :set_list, only: [:show, :edit, :update, :destroy]

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
    @list = List.create(list_params)

    if @list.save
      redirect_to board_path(@list.board_id)
    else
      flash[:error] = "Error: Not Create List"
      redirect_to board_path(@list.board_id)
    end
  end

  def edit
    redirect_to root_path
  end

  def update
    @list.update(list_params)

    if @list.save
      redirect_to board_path(@list.board_id)
    else
      flash[:error] = "Error: Not Update List"
      redirect_to board_path(@list.board_id)
    end
  end

  def destroy
    noTitle = List.find_by(title: "No title", board_id: @list.board_id)

    @list.bookmarks.each do |b|
      b.update(list_id: noTitle.id)
    end

    @list.destroy

    if @list.save
      redirect_to board_path(@list.board_id)
    else
      flash[:error] = "Error: Not Destroy List"
      redirect_to board_path(@list.board_id)
    end
  end

  private
  def set_list
    @list = List.find(params[:id])
  end

  def list_params
  	params.require(:list).permit(:title, :board_id)
  end
end
