# Refinements String class
module StringToJST
  refine String do
    def parse_in_jst
      regex = /(\d+)/
      match_pattern = scan(regex).to_a

      # In this case, string has always not pass value of seconds
      year, month, day, hour, min, sec = [match_pattern, '00'].flatten.map { |x| x.rjust(2, '0') }

      # DateTime.rfc3339('2001-02-03T04:05:06+07:00')
      DateTime.rfc3339("#{year}-#{month}-#{day}T#{hour}:#{min}:#{sec}+09:00")
    end
  end
end

module MyMechanize
  # Fetch weather information from Yahoo!
  class Weather
    using StringToJST

    # @return [String]
    attr_reader :area

    # List of available area
    AREA_URL = {
      tokyo: 'http://weather.yahoo.co.jp/weather/jp/13/4410.html',
      yokohama: 'http://weather.yahoo.co.jp/weather/jp/14/4610.html',
      naha: 'http://weather.yahoo.co.jp/weather/jp/47/9110.html'
      fukuoka: 'http://weather.yahoo.co.jp/weather/40/8210.html'      
    }.freeze

    # Find weather information by XPath
    XPATHS = {
      today_weather:       '(//p[@class="pict"]/text())[1]',
      highest_temperature: '(//li[@class="high"]/em/text())[1]',
      lowest_temperature:  '(//li[@class="low"]/em/text())[1]',
      wash:                '//div[@class="expExpo"]/dl/dd[1]/text()',
      updated_at:          '(//p[@class="yjSt yjw_note_h2"]/text())[1]'
    }.freeze

    # Format XPath data
    FORMATTER = {
      today_weather:       proc { |x| x.to_s },
      updated_at:          proc { |x| x.to_s.parse_in_jst },
      highest_temperature: proc { |x| x.to_s },
      lowest_temperature:  proc { |x| x.to_s },
      wash:                proc { |x| x.to_s }
    }.freeze

    # Fetch weather information by specified area
    # @param area [String]
    # @return [String]
    def initialize(area)
      fail_if_key_not_found(area.to_sym)

      @mechanize = MyMechanize::Client.new(AREA_URL[area.downcase.to_sym])
      @area = area
    end

    # Returns available area keys
    # @return area [Array]
    def self.available_area
      AREA_URL.keys.map(&:to_s)
    end

    def format
      w = weather
      <<-EOF.lines.map(&:strip)
      Area: #{w[:area]}
      Weather: #{w[:today_weather]}
      Temperature(℃): High #{w[:highest_temperature]} / Low #{w[:lowest_temperature]}
      Updated at: #{w[:updated_at]}
      EOF
    end

    # Returns fetched weather information
    # @return [Hash]
    def weather
      hash = {}
      hash[:area] = @area.capitalize.to_s

      XPATHS.keys.each do |key|
        xpath = XPATHS[key]
        value = FORMATTER[key].call(@mechanize.page.xpath(xpath))
        hash[key] = value
      end

      hash
    end

    # Refetch weather information
    # @return [Hash]
    def update
      @mechanize.get(AREA_URL[@area])
      weather
    end

    private

    def fail_if_key_not_found(area)
      unless AREA_URL.key?(area)
        puts "Error! Area Key Has Not Found: #{area.capitalize}"
        puts 'Available area:'

        AREA_URL.keys.each do |key|
          puts "  * #{key.capitalize}"
        end

        fail 'Area Key Has Not Found'
      end
    end
  end
end
