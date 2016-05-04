require 'thor'
require 'csv'
require 'colorize'
require 'color_logger'
require 'steam_profile'

class SteamIDCrawler < Thor

  LOST_PLANET = 'Lost Planet: Extreme Condition'

  package_name 'steam_id_crawler_for_lost_planet'

  desc 'search_lost_planet', 'steam_ids内のSteamIDから、Lost Planetを持っているユーザーを表示'
  long_desc <<-LONGDESC
    steam_ids内のSteamID64から、Lost Planetを持っているユーザーを表示
  LONGDESC
  def search_lost_planet(id = nil)
    logger = ColorLogger.new
    begin
      csv = CSV.foreach("./steam_ids.csv") do |row|
        begin
          steam_profile = SteamProfile.new(row[0])
          logger.info "SteamID: #{steam_profile.steam_id}..."
          STDOUT.flush
          if steam_profile.has_game?(LOST_PLANET)
            logger.info "found", :green
            logger.info "profile: #{steam_profile.get_profile_url()}/\n"
          else
            logger.info "not found\n", :red
          end
        rescue StandardError => e
          logger.error e.to_s+ "\n"
          next
        end
      end
    rescue StandardError => e
      logger.error e.to_s+ "\n"
    end
  end

end
