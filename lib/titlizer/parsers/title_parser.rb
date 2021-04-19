require "nokogiri"

module Titlizer
  module Parsers
    class TitleParser
      def initialize(body)
        @body = body
      end

      def title
        return "Empty" if @body.nil? || @body.empty?

        parsed_data = Nokogiri::HTML.parse(@body)
        parsed_data.title
      rescue StandardError
        "N/A"
      end
    end
  end
end
