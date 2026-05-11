# frozen_string_literal: true

require "set"

require_relative "support/transformer"
require_relative "support/tokenizer"

module Keycase
  module TrainCase
    def self.convert_string(str)
      Keycase::Support::Tokenizer.words(str).map do |word|
        word.capitalize
      end.join("-")
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
      def to_train_case
        self
      end

      def with_train_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_train_case
        Keycase::TrainCase.convert_string(self)
      end
    end

    refine Symbol do
      def to_train_case
        Keycase::TrainCase.convert(self)
      end
    end

    refine Array do
      def with_train_case_keys(options = {})
        Keycase::TrainCase.convert_keys(self, options)
      end
    end

    refine Hash do
      def with_train_case_keys(options = {})
        Keycase::TrainCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def train_case(value)
      TrainCase.convert(value)
    end

    def with_train_case_keys(value, options = {})
      TrainCase.convert_keys(value, options)
    end
  end
end
