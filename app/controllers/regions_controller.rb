class RegionsController < ApplicationController
  def index
    @regions = Region.active.sorted.roots.includes(:children)

    respond_to do |format|
      format.html
      format.json { render json: @regions.as_json(include: :children) }
    end
  end
end
