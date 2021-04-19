require "csv"

module Titlizer
  module Seiralizers
    module PasrserResult
      class CsvSerializer < Base
        def serialize
          return "" unless data.any?

          column_names = data.first&.keys

          CSV.generate do |csv|
            csv << column_names
            data.each do |item|
              csv << item.values_at(*column_names)
            end
          end
        end
      end
    end
  end
end
