# frozen_string_literal: true

module Keycase
  module Support
    module Tokenizer
      module_function

      def words(value)
        value
          .gsub(/(?<=\p{Lu})(?=\p{Lu}\p{Ll})/, "_")
          .gsub(/(?<=[\p{Ll}\p{Nd}])(?=\p{Lu})/, "_")
          .scan(/[\p{L}\p{N}]+/)
      end
    end
  end
end
