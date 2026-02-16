class HomeController < ApplicationController
  def index
    @applets = Applet.includes(:trigger_service, :action_service).limit(5)
  end
end
