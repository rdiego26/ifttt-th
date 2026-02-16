class HomeController < ApplicationController
  def index
    @applets = Applet.includes(:trigger_service, :action_service).limit(5)
    @applets_json = serialize_applets(@applets)
  end

  private

  def serialize_applets(applets)
    applets.map do |applet|
      {
        id: applet.id.to_s,
        name: applet.name,
        description: applet.description,
        enabled: applet.enabled,
        triggerService: {
          id: applet.trigger_service.id.to_s,
          name: applet.trigger_service.name,
          slug: applet.trigger_service.slug,
          iconUrl: applet.trigger_service.icon_url,
          brandColor: applet.trigger_service.brand_color
        },
        actionService: {
          id: applet.action_service.id.to_s,
          name: applet.action_service.name,
          slug: applet.action_service.slug,
          iconUrl: applet.action_service.icon_url,
          brandColor: applet.action_service.brand_color
        }
      }
    end.to_json
  end
end
