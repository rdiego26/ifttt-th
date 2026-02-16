# Service icons using simple placeholder URLs
# In production, these would be real service icons

services_data = [
  {
    name: "Instagram",
    slug: "instagram",
    icon_url: "https://assets.ifttt.com/images/channels/28/icons/monochrome_regular.webp",
    brand_color: "#E1306C"
  },
  {
    name: "Dropbox",
    slug: "dropbox",
    icon_url: "https://assets.ifttt.com/images/channels/440404753/icons/monochrome_regular.webp",
    brand_color: "#0061FF"
  },
  {
    name: "RSS Feed",
    slug: "feed",
    icon_url: "https://assets.ifttt.com/images/channels/4/icons/monochrome_regular.webp",
    brand_color: "#FF6600"
  },
  {
    name: "Gmail",
    slug: "gmail",
    icon_url: "https://assets.ifttt.com/images/channels/33/icons/monochrome_regular.webp",
    brand_color: "#EA4335"
  },
  {
    name: "WordPress",
    slug: "wordpress",
    icon_url: "https://assets.ifttt.com/images/channels/30/icons/monochrome_regular.webp",
    brand_color: "#21759B"
  },
  {
    name: "X (Twitter)",
    slug: "twitter",
    icon_url: "https://assets.ifttt.com/images/channels/2/icons/monochrome_regular.webp",
    brand_color: "#1DA1F2"
  },
  {
    name: "Spotify",
    slug: "spotify",
    icon_url: "https://assets.ifttt.com/images/channels/51464135/icons/monochrome_regular.webp",
    brand_color: "#1DB954"
  },
  {
    name: "Google Sheets",
    slug: "google_sheets",
    icon_url: "https://assets.ifttt.com/images/channels/799977804/icons/monochrome_regular.webp",
    brand_color: "#0F9D58"
  },
  {
    name: "iOS Photos",
    slug: "ios_photos",
    icon_url: "https://assets.ifttt.com/images/channels/78/icons/monochrome_regular.webp",
    brand_color: "#FF9500"
  },
  {
    name: "Google Drive",
    slug: "google_drive",
    icon_url: "https://assets.ifttt.com/images/channels/142226432/icons/monochrome_regular.webp",
    brand_color: "#4285F4"
  }
]

puts "Creating services..."
services = {}
services_data.each do |data|
  service = Service.find_or_create_by!(slug: data[:slug]) do |s|
    s.name = data[:name]
    s.icon_url = data[:icon_url]
    s.brand_color = data[:brand_color]
  end
  services[data[:slug]] = service
  puts "  Created #{service.name}"
end

applets_data = [
  {
    name: "Save Instagram photos to Dropbox",
    description: "Automatically backup every new photo you post on Instagram to your Dropbox account. Never lose a memory again.",
    trigger_service: services["instagram"],
    action_service: services["dropbox"]
  },
  {
    name: "Email me new RSS items",
    description: "Get an email notification whenever there's a new item in an RSS feed you follow. Stay on top of your favorite blogs and news sources.",
    trigger_service: services["feed"],
    action_service: services["gmail"]
  },
  {
    name: "Tweet my new blog posts",
    description: "Automatically share your new WordPress blog posts to Twitter. Grow your audience without the manual work.",
    trigger_service: services["wordpress"],
    action_service: services["twitter"]
  },
  {
    name: "Save Spotify tracks to a spreadsheet",
    description: "Keep a record of every song you save on Spotify in a Google Sheets spreadsheet. Perfect for music lovers who want to track their listening history.",
    trigger_service: services["spotify"],
    action_service: services["google_sheets"]
  },
  {
    name: "Backup phone photos to Google Drive",
    description: "Automatically save every new photo from your iPhone to Google Drive. Your memories are safely stored in the cloud.",
    trigger_service: services["ios_photos"],
    action_service: services["google_drive"]
  }
]

puts "\nCreating applets..."
applets_data.each do |data|
  applet = Applet.find_or_create_by!(name: data[:name]) do |a|
    a.description = data[:description]
    a.trigger_service = data[:trigger_service]
    a.action_service = data[:action_service]
    a.enabled = true
  end
  puts "  Created '#{applet.name}'"
end

puts "\nSeeding complete!"
puts "  #{Service.count} services"
puts "  #{Applet.count} applets"
