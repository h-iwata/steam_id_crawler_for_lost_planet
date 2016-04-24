require 'thor'
require 'net/http'
require 'rexml/document'
require 'csv'
require 'colorize'

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
    steam_idは、64bitのもの（数字のidを使用してください）
  LONGDESC
  def search_lost_planet(id = nil)
    begin
      csv = CSV.foreach("./steam_ids.csv") do |row|
        begin
          steam_id = row[0]
          print "[info] SteamID: #{steam_id}..."
          raise '64bitの SteamID64（数字）を使用してください。名前では検索できません' unless steam_id.is_number?

          if has_game?(get_game_list_from_steam_id(steam_id), LOST_PLANET)
            print "found\n".colorize(:green)
            puts "[info] profile: http://steamcommunity.com/profiles/#{steam_id}/"
          else
            print "not found\n".colorize(:red)
          end
        rescue StandardError => e
          puts "\n[error] ".colorize(:red) + e.to_s
          next
        end
      end
      rescue StandardError => e
    puts "[error] ".colorize(:red) + e.to_s
    end
  end

 private

 def get_game_list_from_steam_id(steam_id)
   steam_community_list_URL = URI.parse("http://steamcommunity.com/profiles/#{steam_id}/games/?tab=all&xml=1")
   response = Net::HTTP.start(steam_community_list_URL.host, steam_community_list_URL.port) do |http|
     http.get(steam_community_list_URL.request_uri)
   end

   gamelist = REXML::Document.new(response.body)
   raise gamelist.elements['response/error'].cdatas().to_s if gamelist.elements['response/error'] != nil
   gamelist
 end

 def has_game?(gamelist, game_name)
   founded = false
   gamelist.elements.each("gamesList/games/game/name") do |game|
     if game.cdatas().to_s == "[\"#{game_name}\"]"
       founded = true
       next
     end
   end
   founded
 end

end
SteamIDCrawler.start(ARGV)
