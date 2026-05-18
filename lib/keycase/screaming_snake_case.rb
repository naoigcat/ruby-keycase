# frozen_string_literal: true

require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module ScreamingSnakeCase
    def self.convert_string(str)
      Keycase::Support::Tokenizer.words(str).map(&:upcase).join("_")
    end

    def self.convert(value)
      case value
      when String then convert_string(value)
      when Symbol then convert_string(value.to_s).to_sym
      else value
      end
    end

    def self.convert_keys(structure, options = {})
      Keycase::Support::StructureKeys.transform(structure, options) do |key|
        convert(key)
      end
    end

    refine Object do
      def to_screaming_snake_case(_options = {})
        self
      end

      def with_screaming_snake_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_screaming_snake_case
        Keycase::ScreamingSnakeCase.convert_string(self)
      end
    end

    refine Symbol do
      def to_screaming_snake_case
        Keycase::ScreamingSnakeCase.convert(self)
      end
    end

    refine Array do
      def with_screaming_snake_case_keys(options = {})
        Keycase::ScreamingSnakeCase.convert_keys(self, options)
      end
    end

    refine Hash do
      def with_screaming_snake_case_keys(options = {})
        Keycase::ScreamingSnakeCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def screaming_snake_case(value)
      ScreamingSnakeCase.convert(value)
    end

    def with_screaming_snake_case_keys(value, options = {})
      ScreamingSnakeCase.convert_keys(value, options)
    end
  end
end
