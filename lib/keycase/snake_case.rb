# frozen_string_literal: true

require "set"

require_relative "support/transformer"
require_relative "support/tokenizer"

module Keycase
  module SnakeCase
    def self.convert_string(str)
      Keycase::Support::Tokenizer.words(str).map do |word|
        word.downcase
      end.join("_")
    end

    def self.convert(value)
      case value
      when String then convert_string(value)
      when Symbol then convert_string(value.to_s).to_sym
      else value
      end
    end

    def self.convert_keys(structure, options = {})
      key_converter = proc do |key|
        convert(key)
      end

      case structure
      when Hash
        Keycase::Support::Transformer.transform_hash(
          structure,
          ::Set.new,
          0,
          options[:max_depth],
          &key_converter
        )
      when Array
        Keycase::Support::Transformer.transform_array(
          structure,
          ::Set.new,
          0,
          options[:max_depth],
          &key_converter
        )
      else
        structure
      end
    end

    refine Object do
      def to_snake_case
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
