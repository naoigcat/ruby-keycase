# frozen_string_literal: true

require_relative "errors"
require_relative "transformer/visit"
require_relative "transformer/only_normalization"

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

        def transform_value(value, state, &key_converter)
          case value
          when Hash
            transform_hash(value, state, &key_converter)
          when Array
            transform_array(value, state, &key_converter)
          else
            value
          end
        end

        private

        def build_transformed_hash(hash, state, on_collision, &key_converter)
          hash.each_with_object({}) do |key_and_value, memo|
            assign_transformed_hash_entry(memo, key_and_value, state, on_collision, &key_converter)
          end
        end

        def assign_transformed_hash_entry(memo, key_and_value, state, on_collision, &key_converter)
          key, value = key_and_value
          new_key = convert_key?(key, state.options) ? key_converter.call(key) : key
          child = child_state(state, :hash)

          if memo.key?(new_key)
            ctx = HashCollision.new(memo, new_key, value, key, child)
            resolve_hash_key_collision!(on_collision, ctx, &key_converter)
          else
            memo[new_key] = transform_value(value, child, &key_converter)
          end
        end

        def child_state(state, parent_kind)
          State.new(state.visiting, state.depth + 1, state.options, parent_kind)
        end

        def resolve_hash_key_collision!(on_collision, collision_details, &key_converter)
          case on_collision
          when :raise
            message = "Keycase detected a key collision: #{collision_details.original_key.inspect} converted to " \
                      "#{collision_details.new_key.inspect}, which already exists in the transformed hash"
            raise KeyCollisionError, message
          when :overwrite
            d = collision_details
            d.memo[d.new_key] = transform_value(d.value, d.child_state, &key_converter)
          when :keep_first
            nil
          end
        end

        def convert_key?(key, options)
          klasses = options[:__keycase_only_klasses]
          return true if klasses.nil?

          klasses.any? do |klass|
            key.is_a?(klass)
          end
        end

        def resolve_on_collision!(options)
          mode = options.fetch(:on_collision, :raise)
          return mode if %i[raise overwrite keep_first].include?(mode)

          raise ArgumentError, "Keycase on_collision must be :raise, :overwrite, or :keep_first (got #{mode.inspect})"
        end

        def check_depth!(depth, max_depth)
          return if max_depth.nil?

          raise StructureTooDeepError, "Keycase nesting exceeds max_depth (#{max_depth})" if depth > max_depth
        end
      end
    end
  end
end
