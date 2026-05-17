# frozen_string_literal: true

require_relative "support/acronyms"
require_relative "support/structure_keys"
require_relative "support/tokenizer"

module Keycase
  module TrainCase
    def self.convert_string(str, acronyms: nil)
      words = Keycase::Support::Tokenizer.words(str)
      acronyms_by_downcase = Keycase::Support::Acronyms.index(acronyms)
      words.map do |word|
        Keycase::Support::Acronyms.segment(word, acronyms_by_downcase)
      end.join("-")
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
      Keycase::Support::StructureKeys.transform(structure, options) do |key|
        convert(key, acronyms: acronyms)
      end
    end

    refine Object do
      def to_train_case(**_keycase)
        self
      end

      def with_train_case_keys(**_keycase)
        self
      end
    end

    refine String do
      def to_train_case(acronyms: nil)
        Keycase::TrainCase.convert_string(self, acronyms: acronyms)
      end
    end

    refine Symbol do
      def to_train_case(acronyms: nil)
        Keycase::TrainCase.convert(self, acronyms: acronyms)
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
    def train_case(value, acronyms: nil)
      TrainCase.convert(value, acronyms: acronyms)
    end

    def with_train_case_keys(value, options = {})
      TrainCase.convert_keys(value, options)
    end
  end
end
