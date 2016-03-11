class PlaceholdersController < ApplicationController

  def show
    @width  = params[:width]
    @height = params[:height]
  end

end
