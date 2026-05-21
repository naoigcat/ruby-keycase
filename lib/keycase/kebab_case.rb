# frozen_string_literal: true

require_relative "support/acronyms"
require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module KebabCase
    def self.convert_string(str, acronyms: nil, capitalize: false)
      words = Keycase::Support::Tokenizer.words(str)
      return words.map(&:downcase).join("-") unless capitalize

      acronyms_by_downcase = Keycase::Support::Acronyms.index(acronyms)
      words.map do |word|
        Keycase::Support::Acronyms.segment(word, acronyms_by_downcase)
      end.join("-")
    end

    def self.convert(value, acronyms: nil, capitalize: false)
      case value
      when String then convert_string(value, acronyms: acronyms, capitalize: capitalize)
      when Symbol then convert_string(value.to_s, acronyms: acronyms, capitalize: capitalize).to_sym
      else value
      end
    end

    def self.convert_keys(structure, options = {})
      acronyms = options[:acronyms]
      capitalize = options.fetch(:capitalize, false)
      Keycase::Support::StructureKeys.transform(structure, options) do |key|
        convert(key, acronyms: acronyms, capitalize: capitalize)
      end
    end

    refine Object do
      def to_kebab_case(_options = {})
        self
      end

      def with_kebab_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_kebab_case(acronyms: nil, capitalize: false)
        Keycase::KebabCase.convert_string(self, acronyms: acronyms, capitalize: capitalize)
      end
    end

    refine Symbol do
      def to_kebab_case(acronyms: nil, capitalize: false)
        Keycase::KebabCase.convert(self, acronyms: acronyms, capitalize: capitalize)
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

    refine Struct do
      def with_kebab_case_keys(options = {})
        Keycase::KebabCase.convert_keys(self, options)
      end
    end
  end

  class << self
    def kebab_case(value, acronyms: nil, capitalize: false)
      KebabCase.convert(value, acronyms: acronyms, capitalize: capitalize)
    end

    def with_kebab_case_keys(value, options = {})
      KebabCase.convert_keys(value, options)
    end
  end
end
