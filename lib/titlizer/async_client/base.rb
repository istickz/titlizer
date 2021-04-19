module Titlizer
  module AsyncClient
    class Base
      class Response
        attr_reader :original_url, :last_location, :status, :body

        def initialize(original_url:, last_location:, status:, body:)
          @original_url = original_url
          @last_location = last_location

          @status = status
          @body = body
        end
      end

      attr_reader :internet, :url, :response

      def initialize(internet:, url:)
        @internet = internet
        @url = url
      end

      DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36".freeze

      REDIRECT_ATTEMPTS = 3

      HTTP_CODES = {
        ok_codes: [
          200
        ],
        redirect_codes: [
          301,
          302,
          303,
          307,
          308
        ]
      }.freeze

      private

      def site_ok?(status)
        HTTP_CODES[:ok_codes].include? status
      end

      def site_redirect?(status)
        HTTP_CODES[:redirect_codes].include? status
      end

      def build_follow_location(request_url, follow_location)
        return URI.parse(request_url).merge(follow_location).to_s unless follow_location.start_with?("http")

        follow_location
      end

      def request_headers
        @request_headers ||= { "user-agent" => DEFAULT_USER_AGENT }
      end
    end
  end
end
