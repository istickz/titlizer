require_relative "parsers/title_parser"
require "async"
require "async/barrier"
require "async/semaphore"
require "async/http/internet"
require "nokogiri"
require "uri"
require "csv"

module Titilizer
  class Parser
    DEFAULT_USER_AGENT = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36".freeze
    REDIRECT_ATTEMPTS = 4

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

    attr_reader :sites, :max_concurrent_requests, :user_agent, :results, :errors, :redirects

    def initialize(sites:, max_concurrent_requests: nil, user_agent: nil)
      raise ArgumentError, "Empty sites" unless sites.any?

      @sites = sites
      @max_concurrent_requests = max_concurrent_requests || Etc.nprocessors * 8
      @user_agent = user_agent || DEFAULT_USER_AGENT
      @results = []
    end

    def parse!
      Async do
        barrier = Async::Barrier.new
        semaphore = Async::Semaphore.new(max_concurrent_requests, parent: barrier)
        internet = Async::HTTP::Internet.new

        sites.each_with_index do |site, index|
          semaphore.async do
            run_async_parser(internet, site, index)
          end
        end
        barrier.wait
      end
    end

    def csv_results
      return [] unless @results.any?

      column_names = @results.first&.keys

      CSV.generate do |csv|
        csv << column_names
        @results.each do |item|
          csv << item.values_at(*column_names)
        end
      end
    end

    private

    def run_async_parser(internet, site, index)
      response = make_request(internet, request_headers, site)

      title = body_to_tile(response[:body])

      @results[index] = build_result(site: site,
                                     status: response[:status],
                                     title: title,
                                     last_location: response[:last_location])
    rescue StandardError => _e
      @results[index] = build_result(site: site, last_location: site, status: "error", title: "N/A")
    end

    def body_to_tile(body)
      tparser = Titlizer::Parsers::TitleParser.new(body)
      tparser.title
    end

    def make_request(internet, headers, url, counter = 0)
      counter += 1

      response = internet.get url, headers
      status = response.status

      if site_redirect?(status) && counter == REDIRECT_ATTEMPTS
        { status: "many_redirects", last_location: url }
      elsif site_redirect?(status)
        location = response.headers["location"]
        new_url = build_follow_location(url, location)
        make_request(internet, headers, new_url, counter)
      elsif site_ok?(status)
        body = response.read
        { status: "ok", last_location: url, body: body }
      else
        { status: "error", last_location: url }
      end
    rescue StandardError
      { status: "error", last_location: url }
    end

    def build_result(site:, status:, last_location:, title: nil)
      h = {
        site: site,
        status: status,
        last_location: last_location
      }
      h[:title] = title if title
      h
    end

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
      @request_headers ||= { "user-agent" => user_agent }
    end
  end
end
