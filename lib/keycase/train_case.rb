# frozen_string_literal: true

require "set"

require_relative "recursive_transform/engine"

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
        gsub(/(?<=[A-Z])(?=[A-Z][a-z])/) do |_|
          "-"
        end.gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
          "-"
        end.gsub(/(?<=\b|\W|_)[0-9A-Za-z]+(?=\b|\W|_)/) do |matched|
          "-#{matched.downcase}"
        end.gsub(/(?:\W|_)+/, "-").gsub(/^(?:\W|_)*|(?:\W|_)*$/, "").downcase.split("-", -1).map(&:capitalize).join("-")
      end
    end

    refine Symbol do
      def to_train_case
        to_s.to_train_case.to_sym
      end
    end

    refine Array do
      def with_train_case_keys(options = {})
        Keycase::RecursiveTransform::Engine.transform_array(
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
        Keycase::RecursiveTransform::Engine.transform_hash(
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
