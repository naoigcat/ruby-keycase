# frozen_string_literal: true

module Keycase
  module Support
    module StructInstantiation
      KEYWORD_INIT_IVAR = :@keycase_keyword_init

      module_function

      def struct_keyword_init_available?
        return @struct_keyword_init_available if defined?(@struct_keyword_init_available)

        available = false
        begin
          Struct.new(:x, keyword_init: true)
          available = true
        rescue TypeError
          available = false
        end
        @struct_keyword_init_available = available
      end

      def mark_keyword_init!(klass)
        klass.instance_variable_set(KEYWORD_INIT_IVAR, true)
      end

      def struct_keyword_init?(klass)
        return false unless struct_keyword_init_available?

        return true if klass.instance_variable_defined?(KEYWORD_INIT_IVAR)

        klass.respond_to?(:keyword_init?) && klass.keyword_init?
      end

      def build_struct_class(*members, keyword_init:)
        if keyword_init && struct_keyword_init_available?
          Struct.new(*members, keyword_init: true).tap do |klass|
            mark_keyword_init!(klass)
          end
        else
          Struct.new(*members)
        end
      end

      def instantiate(klass, pairs, member_order)
        if struct_keyword_init?(klass)
          klass.new(**pairs)
        else
          klass.new(*member_order.map { |member| pairs[member] })
        end
      end
    end
  end
end
