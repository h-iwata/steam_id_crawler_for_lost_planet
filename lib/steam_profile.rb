require 'net/http'
require 'rexml/document'
require 'color_logger'

class String
  def is_number?
    true if Float(self) rescue false
  end
end

class SteamProfile

  attr_reader :steam_id, :user_created
  STEAM_COMMUNITY_URL = 'http://steamcommunity.com/'

  def initialize(steam_id)
    @steam_id = steam_id
    @user_created = !@steam_id.is_number?
    @logger = ColorLogger.new
  end

  def has_game?(game_name)
    game_list = get_game_list()
    return false if game_list.nil? or game_list.empty?

    @logger.info "#{game_list.size} game#{'s' if game_list.size > 1} found, searching..."
    return game_list.find do |game|
      game.cdatas().to_s == "[\"#{game_name}\"]"
    end
  end

  def get_profile_url
    if @user_created
      url = "#{STEAM_COMMUNITY_URL}id/#{@steam_id}"
    else
      url = "#{STEAM_COMMUNITY_URL}profiles/#{@steam_id}"
    end
  end

  private

  def get_game_list()
    url = URI.parse(get_profile_url() + "/games/?tab=all&xml=1")
    @logger.info "profile: #{get_profile_url()}/"
    response = Net::HTTP.start(url.host, url.port) do |http|
      http.get(url.request_uri)
    end

    game_list = REXML::Document.new(response.body)
    if game_list.elements['response/error'] != nil
      if ! @user_created
        @logger.info "/profiles not found but try /id...", :red
        @user_created = true
        return get_game_list()
      end
      raise "url:#{url}\n" + game_list.elements['response/error'].cdatas().to_s
    end
    game_list.elements.to_a("gamesList/games/game/name")
  end

end
