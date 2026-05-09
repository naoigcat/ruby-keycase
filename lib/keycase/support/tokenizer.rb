# frozen_string_literal: true

module Keycase
  module Support
    module Tokenizer
      module_function

      def words(value)
        value
          .gsub(/(?<=[A-Z])(?=[A-Z][a-z])/) do |_|
            "_"
          end
          .gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
            "_"
          end
          .scan(/[0-9A-Za-z]+/)
      end
    end
  end
end
