require "json"

module Titlizer
  module Seiralizers
    module PasrserResult
      class JsonSerializer < Base
        def serialize
          data.to_json
        end
      end
    end
  end
end
