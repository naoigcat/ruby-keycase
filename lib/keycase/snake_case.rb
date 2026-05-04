# frozen_string_literal: true

require "set"

require_relative "recursive_transform/engine"

module Keycase
  module SnakeCase
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
        gsub(/(?<=[A-Z])(?=[A-Z][a-z])/) do |_|
          "_"
        end.gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
          "_"
        end.gsub(/(?<=\b|\W|_)[0-9A-Za-z]+(?=\b|\W|_)/) do |matched|
          "_#{matched.downcase}"
        end.gsub(/(?:\W|_)+/, "_").gsub(/^(?:\W|_)*|(?:\W|_)*$/, "").downcase
      end
    end

    refine Symbol do
      def to_snake_case
        to_s.to_snake_case.to_sym
      end
    end

    refine Array do
      def with_snake_case_keys(options = {})
        Keycase::RecursiveTransform::Engine.transform_array(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_snake_case
        end
      end
    end

    refine Hash do
      def with_snake_case_keys(options = {})
        Keycase::RecursiveTransform::Engine.transform_hash(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_snake_case
        end
      end
    end
  end
end
