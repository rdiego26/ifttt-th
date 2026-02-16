class AppletsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :applet_not_found

  def show
    @applet = Applet.find(params[:id])
  end

  private

  def applet_not_found
    respond_to do |format|
      format.html { render "applets/not_found", status: :not_found, layout: "application" }
      format.json { render json: { error: "Applet not found", message: "Couldn't find Applet with id=#{params[:id]}" }, status: :not_found }
    end
  end
end
