require 'thor'
require 'csv'
require 'colorize'
require 'logger'
require 'steam_profile'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class SteamIDCrawler < Thor

  LOST_PLANET = 'Lost Planet: Extreme Condition'

  package_name 'steam_id_crawler_for_lost_planet'

  desc 'search_lost_planet', 'steam_ids内のSteamIDから、Lost Planetを持っているユーザーを表示'
  long_desc <<-LONGDESC
    steam_ids内のSteamID64から、Lost Planetを持っているユーザーを表示
  LONGDESC
  def search_lost_planet(id = nil)
    logger = get_logger()
    begin
      csv = CSV.foreach("./steam_ids.csv") do |row|
        steam_profile = SteamProfile.new(row[0])
        logger.info "SteamID: #{steam_profile.steam_id}..."
        STDOUT.flush
        if steam_profile.has_game?(LOST_PLANET)
          logger.info "found".colorize(:green)
          logger.info "profile: #{steam_profile.get_profile_url()}/\n"
        else
          logger.info "not found\n".colorize(:red)
        end
      end
    rescue StandardError => e
      logger.error e.to_s+ "\n"
    end
  end

  private

  def get_logger
    logger = Logger.new(STDOUT, 'daily')
    logger.level = Logger::DEBUG
    logger.formatter = proc{|severity, datetime, progname, message|
      level_color = (severity == "ERROR")? :red : :cyan
       "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{"[#{severity}]".colorize(level_color)}  #{message}\n"
    }
    logger
  end

end
