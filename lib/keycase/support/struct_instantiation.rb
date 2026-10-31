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

      def each_member_pair(structure)
        # Struct member accessors can hide the methods used by conversion.
        ::Struct.instance_method(:each_pair).bind(structure).to_enum(:call)
      end

      def rebuild(original, pairs)
        klass = Object.instance_method(:class).bind(original).call
        original_members = each_member_pair(original).map(&:first)
        new_members = pairs.keys

        # Older Rubies cannot identify keyword_init on Struct classes created by callers.
        return copy_struct(original, pairs, klass) if new_members == original_members

        target_klass = build_struct_class(*new_members, keyword_init: struct_keyword_init?(klass))
        instantiate(target_klass, pairs, new_members)
      end

      def instantiate(klass, pairs, member_order)
        instance = klass.allocate
        # A converted member named initialize can hide Struct's initializer.
        initializer = ::Struct.instance_method(:initialize).bind(instance)
        if struct_keyword_init?(klass)
          initializer.call(**pairs)
        else
          values = member_order.map do |member|
            pairs[member]
          end
          initializer.call(*values)
        end
        instance
      end

      def copy_struct(original, pairs, klass)
        copy = duplicate_struct(original, klass)
        writer = ::Struct.instance_method(:[]=).bind(copy)
        pairs.each do |member, value|
          writer.call(member, value)
        end
        copy
      end

      def duplicate_struct(original, klass)
        return Object.instance_method(:dup).bind(original).call unless copy_hooks_shadowed?(klass)

        # dup dispatches copy hooks, which member accessors can hide.
        copy = Class.instance_method(:allocate).bind(klass).call
        ::Struct.instance_method(:initialize_copy).bind(copy).call(original)
        copy_instance_variables(original, copy)
        copy
      end

      def copy_hooks_shadowed?(klass)
        (%i[initialize_dup initialize_copy] & klass.members).any? do |hook|
          klass.instance_method(hook).arity.zero?
        end
      end

      def copy_instance_variables(original, copy)
        reader = Object.instance_method(:instance_variable_get).bind(original)
        writer = Object.instance_method(:instance_variable_set).bind(copy)
        Object.instance_method(:instance_variables).bind(original).call.each do |name|
          writer.call(name, reader.call(name))
        end
      end
      private_class_method :copy_struct, :duplicate_struct, :copy_hooks_shadowed?, :copy_instance_variables
    end
  end
end
