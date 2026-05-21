# frozen_string_literal: true

require_relative "errors"
require_relative "struct_instantiation"
require_relative "transformer/visit"
require_relative "transformer/only_normalization"
require_relative "transformer/collision"
require_relative "transformer/structure_builders"

module Keycase
  module Support
    module Transformer
      State = Struct.new(:visiting, :depth, :options, :parent_kind)
      HashCollision = Struct.new(:memo, :new_key, :value, :original_key, :child_state)

      class << self
        def enrich_options(options)
          recursive = options.fetch(:recursive, true)
          arrays = options.fetch(:arrays, true)
          unless [true, false].include?(recursive)
            raise ArgumentError, "Keycase recursive must be true or false (got #{recursive.inspect})"
          end
          unless [true, false].include?(arrays)
            raise ArgumentError, "Keycase arrays must be true or false (got #{arrays.inspect})"
          end

          options.merge(
            recursive: recursive,
            arrays: arrays,
            __keycase_only_klasses: normalize_only_classes(options[:only])
          )
        end

        def transform_hash(hash, state, &key_converter)
          return hash if state.options[:recursive] == false && state.parent_kind == :hash

          on_collision = resolve_on_collision!(state.options)
          check_depth!(state.depth, state.options[:max_depth])

          visit_structure(hash, state.visiting, "Hash") do
            build_transformed_hash(hash, state, on_collision, &key_converter)
          end
        end

        def transform_array(array, state, &key_converter)
          return array.map(&:itself) if state.options[:arrays] == false

          check_depth!(state.depth, state.options[:max_depth])

          visit_structure(array, state.visiting, "Array") do
            child = child_state(state, :array)
            array.map do |element|
              transform_value(element, child, &key_converter)
            end
          end
        end

        def transform_struct(struct, state, &key_converter)
          return struct if state.options[:recursive] == false && state.parent_kind == :struct

          on_collision = resolve_on_collision!(state.options)
          check_depth!(state.depth, state.options[:max_depth])

          visit_structure(struct, state.visiting, "Struct") do
            pairs = build_transformed_member_map(struct, state, on_collision, &key_converter)
            instantiate_struct(struct, pairs)
          end
        end

        def transform_value(value, state, &key_converter)
          case value
          when Hash
            transform_hash(value, state, &key_converter)
          when Array
            transform_array(value, state, &key_converter)
          when ::Struct
            transform_struct(value, state, &key_converter)
          else
            value
          end
        end

        private

        def build_transformed_hash(hash, state, on_collision, &key_converter)
          hash.each_with_object({}) do |key_and_value, memo|
            entry_options = member_entry_options(state, on_collision, :hash)
            assign_transformed_member_entry(memo, key_and_value, entry_options, &key_converter)
          end
        end

        def child_state(state, parent_kind)
          State.new(state.visiting, state.depth + 1, state.options, parent_kind)
        end
      end
    end
  end
end
