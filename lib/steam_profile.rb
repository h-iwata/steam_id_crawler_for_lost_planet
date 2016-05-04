require 'net/http'
require 'rexml/document'

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
    get_game_list().each do |game|
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
    raise "url:#{url}\n" + gamelist.elements['response/error'].cdatas().to_s if gamelist.elements['response/error'] != nil
    gamelist.elements.to_a("gamesList/games/game/name")
  end
end
