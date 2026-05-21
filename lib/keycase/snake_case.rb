# frozen_string_literal: true

require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module SnakeCase
    def self.convert_string(str, upcase: false)
      words = Keycase::Support::Tokenizer.words(str)
      converter = upcase ? :upcase : :downcase
      words.map(&converter).join("_")
    end

    def self.convert(value, upcase: false)
      case value
      when String then convert_string(value, upcase: upcase)
      when Symbol then convert_string(value.to_s, upcase: upcase).to_sym
      else value
      end
    end

    def self.convert_keys(structure, options = {})
      upcase = options.fetch(:upcase, false)
      Keycase::Support::StructureKeys.transform(structure, options) do |key|
        convert(key, upcase: upcase)
      end
    end

    refine Object do
      def to_snake_case(_options = {})
        self
      end

      def with_snake_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_snake_case(upcase: false)
        Keycase::SnakeCase.convert_string(self, upcase: upcase)
      end
    end

    refine Symbol do
      def to_snake_case(upcase: false)
        Keycase::SnakeCase.convert(self, upcase: upcase)
      end
    end

    refine Array do
      def with_snake_case_keys(options = {})
        Keycase::SnakeCase.convert_keys(self, options)
      end
    end

    refine Hash do
      def with_snake_case_keys(options = {})
        Keycase::SnakeCase.convert_keys(self, options)
      end
    end

    refine Struct do
      def with_snake_case_keys(options = {})
        Keycase::SnakeCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def snake_case(value, upcase: false)
      SnakeCase.convert(value, upcase: upcase)
    end

    def with_snake_case_keys(value, options = {})
      SnakeCase.convert_keys(value, options)
    end
  end
end
