# frozen_string_literal: true

require_relative "errors"

module Keycase
  module Support
    module Transformer
      class << self
        def transform_hash(hash, visiting, depth, options, &key_converter)
          max_depth = options[:max_depth]
          on_collision = resolve_on_collision!(options)

          check_depth!(depth, max_depth)

          oid = hash.object_id
          raise CircularStructureError, "Keycase detected a circular reference in a Hash" if visiting.include?(oid)

          visiting.add(oid)
          begin
            hash.each_with_object({}) do |(key, value), memo|
              new_key = key_converter.call(key)
              if memo.key?(new_key)
                case on_collision
                when :raise
                  message = "Keycase detected a key collision: #{key.inspect} converted to " \
                            "#{new_key.inspect}, which already exists in the transformed hash"
                  raise KeyCollisionError, message
                when :overwrite
                  memo[new_key] = transform_value(value, visiting, depth + 1, options, &key_converter)
                when :keep_first
                  # memo[new_key] already holds the first value
                end
              else
                memo[new_key] = transform_value(value, visiting, depth + 1, options, &key_converter)
              end
            end
          ensure
            visiting.delete(oid)
          end
        end

        def transform_array(array, visiting, depth, options, &key_converter)
          max_depth = options[:max_depth]
          check_depth!(depth, max_depth)

          oid = array.object_id
          raise CircularStructureError, "Keycase detected a circular reference in an Array" if visiting.include?(oid)

          visiting.add(oid)
          begin
            array.map do |element|
              transform_value(
                element,
                visiting,
                depth + 1,
                options,
                &key_converter
              )
            end
          ensure
            visiting.delete(oid)
          end
        end

        def transform_value(value, visiting, depth, options, &key_converter)
          case value
          when Hash
            transform_hash(value, visiting, depth, options, &key_converter)
          when Array
            transform_array(value, visiting, depth, options, &key_converter)
          else
            value
          end
        end

        private

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
