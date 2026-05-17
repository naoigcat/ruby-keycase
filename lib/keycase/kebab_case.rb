# frozen_string_literal: true

require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module KebabCase
    def self.convert_string(str)
      Keycase::Support::Tokenizer.words(str).map do |word|
        word.downcase
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
      Keycase::Support::StructureKeys.transform(structure, options) do |key|
        convert(key)
      end
    end

    refine Object do
      def to_kebab_case(**_keycase)
        self
      end

      def with_kebab_case_keys(**_keycase)
        self
      end
    end

    refine String do
      def to_kebab_case
        Keycase::KebabCase.convert_string(self)
      end
    end

    refine Symbol do
      def to_kebab_case
        Keycase::KebabCase.convert(self)
      end
    end

    refine Array do
      def with_kebab_case_keys(options = {})
        Keycase::KebabCase.convert_keys(self, options)
      end
    end

    refine Hash do
      def with_kebab_case_keys(options = {})
        Keycase::KebabCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def kebab_case(value)
      KebabCase.convert(value)
    end

    def with_kebab_case_keys(value, options = {})
      KebabCase.convert_keys(value, options)
    end
  end
end
