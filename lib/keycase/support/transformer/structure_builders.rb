# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def build_transformed_member_map(structure, state, on_collision, &key_converter)
          each_member_pair(structure).with_object({}) do |key_and_value, memo|
            entry_options = member_entry_options(state, on_collision, :struct)
            assign_transformed_member_entry(memo, key_and_value, entry_options, &key_converter)
          end
        end

        def member_entry_options(state, on_collision, child_parent_kind)
          {
            state: state,
            on_collision: on_collision,
            child_parent_kind: child_parent_kind
          }
        end

        def each_member_pair(structure)
          # Struct member accessors can hide the methods used by conversion.
          ::Struct.instance_method(:each_pair).bind(structure).to_enum(:call)
        end

        def assign_transformed_member_entry(memo, key_and_value, entry_options, &key_converter)
          state = entry_options.fetch(:state)
          on_collision = entry_options.fetch(:on_collision)
          child_parent_kind = entry_options.fetch(:child_parent_kind)
          key, value = key_and_value
          new_key = convert_key?(key, state.options) ? key_converter.call(key) : key
          child = child_state(state, child_parent_kind)
          store_options = {
            memo: memo,
            new_key: new_key,
            value: value,
            original_key: key,
            child: child,
            on_collision: on_collision
          }
          store_transformed_member!(store_options, &key_converter)
        end

        def store_transformed_member!(store_options, &key_converter)
          memo = store_options.fetch(:memo)
          new_key = store_options.fetch(:new_key)
          if memo.key?(new_key)
            ctx = HashCollision.new(
              memo,
              new_key,
              store_options.fetch(:value),
              store_options.fetch(:original_key),
              store_options.fetch(:child)
            )
            resolve_member_key_collision!(store_options.fetch(:on_collision), ctx, &key_converter)
          else
            memo[new_key] = transform_value(store_options.fetch(:value), store_options.fetch(:child), &key_converter)
          end
        end

        def instantiate_struct(original, pairs)
          klass = Object.instance_method(:class).bind(original).call
          original_members = each_member_pair(original).map(&:first)
          new_members = pairs.keys

          # Older Rubies cannot identify keyword_init on Struct classes created by callers.
          return copy_struct(original, pairs, klass) if new_members == original_members

          target_klass = build_struct_class(*new_members, keyword_init: struct_keyword_init?(klass))
          StructInstantiation.instantiate(target_klass, pairs, new_members)
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

        def build_struct_class(*members, keyword_init:)
          StructInstantiation.build_struct_class(*members, keyword_init: keyword_init)
        end

        def struct_keyword_init?(klass)
          StructInstantiation.struct_keyword_init?(klass)
        end
      end
    end
  end
end
