# frozen_string_literal: true

require "set"

require_relative "support/acronyms"
require_relative "support/transformer"
require_relative "support/tokenizer"

module Keycase
  module CamelCase
    def self.convert_string(str, acronyms: nil)
      words = Keycase::Support::Tokenizer.words(str)
      acronyms_by_downcase = Keycase::Support::Acronyms.index(acronyms)
      segments = words.map do |word|
        Keycase::Support::Acronyms.segment(word, acronyms_by_downcase)
      end
      pascal = segments.join
      return pascal if Keycase::Support::Acronyms.leading_acronym?(words.first, acronyms_by_downcase)

      pascal.sub(/^./, &:downcase)
    end

    def self.convert(value, acronyms: nil)
      case value
      when String then convert_string(value, acronyms: acronyms)
      when Symbol then convert_string(value.to_s, acronyms: acronyms).to_sym
      else value
      end
    end

    def self.convert_keys(structure, options = {})
      acronyms = options[:acronyms]
      key_converter = proc do |key|
        convert(key, acronyms: acronyms)
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
      def to_camel_case(**_keycase)
        self
      end

      def with_camel_case_keys(**_keycase)
        self
      end
    end

    refine String do
      def to_camel_case(acronyms: nil)
        Keycase::CamelCase.convert_string(self, acronyms: acronyms)
      end
    end

    refine Symbol do
      def to_camel_case(acronyms: nil)
        Keycase::CamelCase.convert(self, acronyms: acronyms)
      end
    end

    refine Array do
      def with_camel_case_keys(options = {})
        Keycase::CamelCase.convert_keys(self, options)
      end
    end

    refine Hash do
      def with_camel_case_keys(options = {})
        Keycase::CamelCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def camel_case(value, acronyms: nil)
      CamelCase.convert(value, acronyms: acronyms)
    end

    def with_camel_case_keys(value, options = {})
      CamelCase.convert_keys(value, options)
    end
  end
end
