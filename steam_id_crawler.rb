require 'thor'
require 'net/http'
require 'rexml/document'
require 'csv'
require 'colorize'
require 'logger'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class MultiIO
  def initialize(*targets)
     @targets = targets
  end

  def write(*args)
    @targets.each {|t| t.write(*args)}
  end

  def close
    @targets.each(&:close)
  end
end

class SteamProfile

  attr_reader :steam_id

  def initialize(steam_id)
    @steam_id = steam_id
  end

  def has_game?(game_name)
    get_game_list().elements.each("gamesList/games/game/name") do |game|
      if game.cdatas().to_s == "[\"#{game_name}\"]"
        return true
      end
    end
    return false
  end

  def get_profile_url
    if @steam_id.is_number?
      url = "http://steamcommunity.com/profiles/#{@steam_id}"
    else
      url = "http://steamcommunity.com/id/#{@steam_id}"
    end
  end

  private

  def get_game_list()
    url = URI.parse(get_profile_url() + "/games/?tab=all&xml=1")
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.get(url.request_uri)
    end

    gamelist = REXML::Document.new(response.body)
    raise gamelist.elements['response/error'].cdatas().to_s if gamelist.elements['response/error'] != nil
    gamelist
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
    logger = Logger.new(STDOUT, 'daily')
    logger.level = Logger::DEBUG
    logger.formatter = proc{|severity, datetime, progname, message|
      level_color = (severity == "ERROR")? :red : :cyan
       "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} #{"[#{severity}]".colorize(level_color)}  #{message}\n"
    }
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

end
SteamIDCrawler.start(ARGV)
