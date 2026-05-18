# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def normalize_only_classes(only)
          return nil if only.nil?

          raise ArgumentError, "Keycase only must be an Array (got #{only.class})" unless only.is_a?(Array)

          return [] if only.empty?

          only.map do |spec|
            normalize_only_spec(spec)
          end
        end

        def normalize_only_spec(spec)
          case spec
          when Class
            assert_only_allowed_class!(spec)
            spec
          when :string, "string" then String
          when :symbol, "symbol" then Symbol
          else
            raise ArgumentError, "Keycase only: unsupported entry #{spec.inspect}"
          end
        end

        def assert_only_allowed_class!(spec)
          return if [String, Symbol].include?(spec)

          raise ArgumentError,
                "Keycase only allows String and Symbol as classes (got #{spec})"
        end
      end
    end
  end
end
