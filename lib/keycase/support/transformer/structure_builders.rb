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
          structure.each_pair
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
          klass = original.class
          original_members = each_member_pair(original).map(&:first)
          new_members = pairs.keys

          target_klass =
            if new_members == original_members
              klass
            else
              build_struct_class(*new_members, keyword_init: struct_keyword_init?(klass))
            end

          StructInstantiation.instantiate(target_klass, pairs, new_members)
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
