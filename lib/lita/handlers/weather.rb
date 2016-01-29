require 'my_mechanize/client'
require 'my_mechanize/weather'

module Lita
  module Handlers
    class Weather < Handler
      # insert handler code here
      http.post '/weather', :weather_http
      route(/weather\s(.+)/i, :weather)

      def weather_http(request, response)
        area = request.env['rack.input'][:text]

        unless MyMechanize::Weather.available_area.include?(area)
          response.reply("Couldn't search that area")
          return
        end

        weather_info = fetch_weather(area)

        response.body << { text: weather_info.join("\n") }.to_json
      end

      def weather(response)
        area = response.match_data[1]

        unless MyMechanize::Weather.available_area.include?(area)
          response.reply("Couldn't search that area")
          return
        end

        weather_info = fetch_weather(area)
        # response.reply(response.matches.first)
        weather_info.map do |x|
          response.reply(x)
        end
        # response.reply(weather_info)
      end

      def fetch_weather(area)
        weather_info = MyMechanize::Weather.new(area)
        weather_info.format
      end

      Lita.register_handler(self)
    end
  end
end
