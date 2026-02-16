class AppletsController < ApplicationController
  def show
    @applet = Applet.find(params[:id])
  end
end
