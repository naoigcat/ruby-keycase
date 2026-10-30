# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def build_transformed_struct(struct, state, on_collision, &key_converter)
          pairs = build_transformed_members(
            StructInstantiation.each_member_pair(struct), child_state(state, :struct), on_collision
          ) do |key|
            new_key = key_converter.call(key)
            # Struct cannot define an empty member name.
            new_key.to_s.empty? ? key : new_key
          end
          StructInstantiation.rebuild(struct, pairs)
        end

        def build_transformed_members(members, child, on_collision, &key_converter)
          result = members.is_a?(Hash) && members.compare_by_identity? ? {}.compare_by_identity : {}
          members.each_with_object(result) do |(key, value), memo|
            new_key = convert_key?(key, child.options) ? key_converter.call(key) : key
            next if keep_existing_key?(memo, new_key, key, on_collision)

            memo[new_key] = transform_value(value, child, &key_converter)
          end
        end
      end
    end
  end
end
