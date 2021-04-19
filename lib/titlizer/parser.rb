require "async"
require "async/barrier"
require "async/semaphore"
require "async/http/internet"
require "nokogiri"
require "uri"
require "csv"

require_relative "async_client/base"
require_relative "async_client/get_request"
require_relative "parsers/title_parser"
require_relative "serializers/parser_result/base"
require_relative "serializers/parser_result/csv_serializer"
require_relative "serializers/parser_result/json_serializer"
require_relative "serializers/parser_result/terminal_table_serializer"

module Titilizer
  class Parser
    attr_reader :sites, :max_concurrent_requests, :results, :errors, :redirects

    def initialize(sites:, max_concurrent_requests: nil)
      raise ArgumentError, "Empty sites" unless sites.any?

      @sites = sites
      @max_concurrent_requests = max_concurrent_requests || Etc.nprocessors * 8
      @results = []
    end

    def parse!
      Async do
        barrier = Async::Barrier.new
        semaphore = Async::Semaphore.new(max_concurrent_requests, parent: barrier)
        internet = Async::HTTP::Internet.new

        sites.each_with_index do |site, index|
          semaphore.async do |task|
            task.with_timeout(15) do
              run_async_parser(internet, site, index)
            end
          rescue Async::TimeoutError
            @results[index] = build_result(site: site, last_location: site, status: "timeout", title: "Timeout Error")
          end
        end

        barrier.wait
      ensure
        internet&.close
      end
    end

    private

    def run_async_parser(internet, site, index)
      client = Titlizer::AsyncClient::GetRequest.new(internet: internet, url: site)
      client.execute

      title = body_to_tile(client.response.body)

      @results[index] = build_result(site: client.response.original_url,
                                     status: client.response.status,
                                     title: title,
                                     last_location: client.response.last_location)
    rescue StandardError => _e
      @results[index] = build_result(site: site, last_location: site, status: "error", title: "N/A")
    end

    def body_to_tile(body)
      tparser = Titlizer::Parsers::TitleParser.new(body)
      tparser.title
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
  end
end
