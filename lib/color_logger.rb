class ColorLogger

  LOG_FILE = "log.txt"
  ERROR_LOG_FILE = "errors.txt"

  def info(message, message_color = nil)
    puts format_message('INFO', message, true, message_color)
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

  def format_message(severity, message, is_stdout = false, message_color = nil)
    if is_stdout
      severity = "[#{severity}]".colorize((severity == "ERROR")? :red : :cyan)
      message = message.colorize(message_color) unless message_color.nil?
    else
      severity = "[#{severity}]"
    end
    "#{DateTime.now.strftime('%Y-%m-%d %H:%M:%S')} #{severity}  #{message}\n"
  end

end
