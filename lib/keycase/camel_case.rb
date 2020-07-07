module Keycase
  module CamelCase
    refine Object do
      def to_camel_case
        self
      end

      def with_camel_case_keys
        self
      end
    end

    refine String do
      def to_camel_case
        gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
          "_"
        end.gsub(/(?<=\b|\W|_)[0-9A-Za-z]+(?=\b|\W|_)/) do |matched| # rubocop:disable Style/SymbolProc
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
      def with_camel_case_keys
        map do |value| # rubocop:disable Style/SymbolProc
          value.with_camel_case_keys
        end
      end
    end

    refine Hash do
      def with_camel_case_keys
        each_with_object({}) do |(key, value), memo|
          memo[key.to_camel_case] = value.with_camel_case_keys
        end
      end
    end
  end
end
