require 'mechanize'

module MyMechanize
  # Fetch web page by Mechanize
  class Client
    attr_reader :page

    # Init Mechanize and fetch page
    # @param url [String]
    def initialize(url)
      @client = Mechanize.new
      get(url)
    end

    # Fetch url
    # @param url [String]
    # @return Mechanize::Page
    # @see http://mechanize.rubyforge.org/Mechanize/Page.html
    def get(url)
      @page = @client.get(url)
    end
  end
end
