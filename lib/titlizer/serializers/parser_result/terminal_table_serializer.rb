require "tty-table"

module Titlizer
  module Seiralizers
    module PasrserResult
      class TerminalTableSerializer < Base
        def serialize
          return TTY::Table.new([], [[]]) unless data.any?

          headers = data.first&.keys
          rows = data.map { |i| i.values_at(*headers) }
          TTY::Table.new(headers, rows)
        end
      end
    end
  end
end
