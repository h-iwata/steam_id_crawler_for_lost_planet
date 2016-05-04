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

class ColorLoger

  LOG_FILE = "log.txt"
  ERROR_LOG_FILE = "errors.txt"

  def info(message)
    puts format_message('INFO', message, true)
    file = File::open(LOG_FILE, 'a')
    file.puts format_message('INFO', message)
    file.close
  end

  def error(message)
    puts format_message('ERROR', message, true)
    file = File::open(LOG_FILE, 'a')
    file.puts format_message('ERROR', message)
    file.close

    file = File::open(ERROR_LOG_FILE, 'a')
    file.puts format_message('ERROR', message)
    file.close
  end

  private

  def format_message(severity, message, is_stdout = false)
    if is_stdout
      severity = "[#{severity}]".colorize((severity == "ERROR")? :red : :cyan)
    else
      severity = "[#{severity}]"
    end
    "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} #{severity}  #{message}\n"
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
    logger = ColorLoger.new
    begin
      csv = CSV.foreach("./steam_idsa.csv") do |row|
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
