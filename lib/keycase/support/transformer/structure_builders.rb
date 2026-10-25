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
          members.each_with_object({}) do |(key, value), memo|
            new_key = convert_key?(key, child.options) ? key_converter.call(key) : key
            next if keep_existing_key?(memo, new_key, key, on_collision)

            memo[new_key] = transform_value(value, child, &key_converter)
          end
        end
      end
    end
  end
end
