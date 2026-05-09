# frozen_string_literal: true

require "set"

require_relative "support/transformer"
require_relative "support/tokenizer"

module Keycase
  module KebabCase
    refine Object do
      def to_kebab_case
        self
      end

      def with_kebab_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_kebab_case
        Keycase::Support::Tokenizer.words(self).map do |word|
          word.downcase
        end.join("-")
      end
    end

    refine Symbol do
      def to_kebab_case
        to_s.to_kebab_case.to_sym
      end
    end

    refine Array do
      def with_kebab_case_keys(options = {})
        Keycase::Support::Transformer.transform_array(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_kebab_case
        end
      end
    end

    refine Hash do
      def with_kebab_case_keys(options = {})
        Keycase::Support::Transformer.transform_hash(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_kebab_case
        end
      end
    end
  end
end
