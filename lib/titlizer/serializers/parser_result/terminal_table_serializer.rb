require "terminal-table"

module Titlizer
  module Seiralizers
    module PasrserResult
      class TerminalTableSerializer < Base
        def serialize
          items = data || []

          Terminal::Table.new do |v|
            v.title = "Results"
            v.headings = items[0]
            v.rows = items[1..]
          end
        end
      end
    end
  end
end
