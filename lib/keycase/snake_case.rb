# frozen_string_literal: true

require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module SnakeCase
    def self.convert_string(str)
      Keycase::Support::Tokenizer.words(str).map(&:downcase).join("_")
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
      def to_snake_case(_options = {})
        self
      end

      def with_snake_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_snake_case
        Keycase::SnakeCase.convert_string(self)
      end
    end

    refine Symbol do
      def to_snake_case
        Keycase::SnakeCase.convert(self)
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
    def snake_case(value)
      SnakeCase.convert(value)
    end

    def with_snake_case_keys(value, options = {})
      SnakeCase.convert_keys(value, options)
    end
  end
end
