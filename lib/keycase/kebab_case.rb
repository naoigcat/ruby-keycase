# frozen_string_literal: true

module Keycase
  module KebabCase
    refine Object do
      def to_kebab_case
        self
      end

      def with_kebab_case_keys
        self
      end
    end

    refine String do
      def to_kebab_case
        gsub(/(?<=[0-9a-z])(?=[A-Z])/) do |_|
          "-"
        end.gsub(/(?<=\b|\W|_)[0-9A-Za-z]+(?=\b|\W|_)/) do |matched|
          "-#{matched.downcase}"
        end.gsub(/(?:\W|_)+/, "-").gsub(/^(?:\W|_)*|(?:\W|_)*$/, "").downcase
      end
    end

    refine Symbol do
      def to_kebab_case
        to_s.to_kebab_case.to_sym
      end
    end

    refine Array do
      def with_kebab_case_keys
        map do |value| # rubocop:disable Style/SymbolProc
          value.with_kebab_case_keys
        end
      end
    end

    refine Hash do
      def with_kebab_case_keys
        each_with_object({}) do |(key, value), memo|
          memo[key.to_kebab_case] = value.with_kebab_case_keys
        end
      end
    end
  end
end
