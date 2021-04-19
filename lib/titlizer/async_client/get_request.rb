module Titlizer
  module AsyncClient
    class GetRequest < Base
      def execute
        res = make_request(internet, url, request_headers)

        @response = Response.new(
          original_url: url,
          last_location: res[:last_location],
          status: res[:status],
          body: res[:body]
        )
      end

      private

      def make_request(internet, url, headers, counter = 0)
        counter += 1

        res = internet.get url, headers

        status = res.status
        body = res.read

        if site_ok?(status)
          { status: "ok", last_location: url, body: body }
        elsif site_redirect?(status) && counter == REDIRECT_ATTEMPTS
          { status: "many_redirects", last_location: url, body: body }
        elsif site_redirect?(status)
          location = res.headers["location"]
          new_url = build_follow_location(url, location)
          make_request(internet, new_url, headers, counter)
        else
          { status: "error", last_location: url, body: body }
        end
      end
    end
  end
end
