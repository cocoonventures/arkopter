class StockItemsController < ApplicationController
  def new
  end

  def create
    @stock_item = StockItem.create(strong_params)
  end

  def update
  end

  def edit
  end

  def destroy
  end

  def index
  end

  def show
  end

  private

  def strong_params
    params.require(:stock_item).permit(:name,:quantity, :price)  # yeah I know, permiting alls isn't secure, but good for now
  end

  alias_method  :strongp, :strong_params
  alias_method  :sparams, :strong_params
end
