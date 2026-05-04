# frozen_string_literal: true

require "set"

require_relative "recursive_transform/engine"

module Keycase
  module CamelCase
    refine Object do
      def to_camel_case
        self
      end

      def with_camel_case_keys(_options = {})
        self
      end
    end

    refine String do
      def to_camel_case
        gsub(/(?<=[A-Z])(?=[A-Z][a-z])/) do |_|
          "_"
        end.gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
          "_"
        end.gsub(/(?<=\b|\W|_)[0-9A-Za-z]+(?=\b|\W|_)/) do |matched|
          matched.capitalize
        end.sub(/^(?:\W|_)*([A-Z]+(?=[A-Z][0-9A-Za-z]|\d|$)|[A-Z][a-z])/) do |_|
          Regexp.last_match(1).downcase
        end.gsub(/(?:\b|\W|_)*([0-9A-Z])/) do |_|
          Regexp.last_match(1)
        end.gsub(/(?:\W|_)*$/, "")
      end
    end

    refine Symbol do
      def to_camel_case
        to_s.to_camel_case.to_sym
      end
    end

    refine Array do
      def with_camel_case_keys(options = {})
        Keycase::RecursiveTransform::Engine.transform_array(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_camel_case
        end
      end
    end

    refine Hash do
      def with_camel_case_keys(options = {})
        Keycase::RecursiveTransform::Engine.transform_hash(
          self,
          ::Set.new,
          0,
          options[:max_depth]
        ) do |key|
          key.to_camel_case
        end
      end
    end
  end
end
