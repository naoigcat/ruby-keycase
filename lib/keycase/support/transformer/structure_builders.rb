# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def build_transformed_struct(struct, state, on_collision, &key_converter)
          pairs = build_transformed_members(
            StructInstantiation.each_member_pair(struct), child_state(state, :struct), on_collision, &key_converter
          )
          StructInstantiation.rebuild(struct, pairs)
        end

        def build_transformed_members(members, child, on_collision, &key_converter)
          result = members.is_a?(Hash) && members.compare_by_identity? ? {}.compare_by_identity : {}
          members.each_with_object(result) do |(key, value), memo|
            new_key = convert_member_key(key, child, &key_converter)
            next if keep_existing_key?(memo, new_key, key, on_collision)

            memo[new_key] = transform_value(value, child, &key_converter)
          end
        end

        def convert_member_key(key, state, &key_converter)
          return key unless convert_key?(key, state.options)

          new_key = key_converter.call(key)
          # Only Struct members prohibit empty names; nested Hash keys may be empty.
          return key if state.parent_kind == :struct && new_key.to_s.empty?

          new_key
        end
      end
    end
  end
end
