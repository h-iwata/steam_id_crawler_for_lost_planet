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

  private

  def get_game_list()
    if @steam_id.is_number?
      url = "http://steamcommunity.com/profiles/#{@steam_id}/games/?tab=all&xml=1"
    else
      url = "http://steamcommunity.com/id/#{@steam_id}/games/?tab=all&xml=1"
    end
    steam_community_list_URL = URI.parse(url)
    response = Net::HTTP.start(steam_community_list_URL.host, steam_community_list_URL.port) do |http|
      http.get(steam_community_list_URL.request_uri)
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
    #logger = Logger.new('log.txt', 'daily')
    logger = Logger.new(STDOUT, 'daily')
    logger.level = Logger::DEBUG
    logger.formatter = proc{|severity, datetime, progname, message|
       "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{message}\n"
    }
    begin
      csv = CSV.foreach("./steam_ids.csv") do |row|
        steam_profile = SteamProfile.new(row[0])
        logger.info "SteamID: #{steam_profile.steam_id}..."
        STDOUT.flush
        if steam_profile.has_game?(LOST_PLANET)
          logger.info "found".colorize(:green)
          logger.info "profile: http://steamcommunity.com/profiles/#{steam_profile.steam_id}/\n"
        else
          logger.info "not found\n".colorize(:red)
        end
      end
    rescue StandardError => e
      logger.error "[error] ".colorize(:red) + e.to_s + "\n"
    end
  end

end
SteamIDCrawler.start(ARGV)
