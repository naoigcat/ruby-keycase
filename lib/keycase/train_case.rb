# frozen_string_literal: true

require "set"

require_relative "support/transformer"
require_relative "support/tokenizer"

module Keycase
  module TrainCase
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
        Keycase::Support::Tokenizer.words(self).map do |word|
          word.capitalize
        end.join("-")
      end
    end

    refine Symbol do
      def to_train_case
        to_s.to_train_case.to_sym
      end
    end

    refine Array do
      def with_train_case_keys(options = {})
        Keycase::Support::Transformer.transform_array(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_train_case
        end
      end
    end

    refine Hash do
      def with_train_case_keys(options = {})
        Keycase::Support::Transformer.transform_hash(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_train_case
        end
      end
    end
  end
end
