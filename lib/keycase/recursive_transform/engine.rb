# frozen_string_literal: true

require_relative "errors"

module Keycase
  module RecursiveTransform
    module Engine
      class << self
        def transform_hash(hash, visiting, depth, max_depth, &key_converter)
          check_depth!(depth, max_depth)

          oid = hash.object_id
          raise CircularStructureError, "Keycase detected a circular reference in a Hash" if visiting.include?(oid)

          visiting.add(oid)
          begin
            hash.each_with_object({}) do |(key, value), memo|
              new_key = key_converter.call(key)
              if memo.key?(new_key)
                message = "Keycase detected a key collision: #{key.inspect} converted to " \
                          "#{new_key.inspect}, which already exists in the transformed hash"
                raise KeyCollisionError, message
              end

              memo[new_key] = transform_value(
                value,
                visiting,
                depth + 1,
                max_depth,
                &key_converter
              )
            end
          ensure
            visiting.delete(oid)
          end
        end

        def transform_array(array, visiting, depth, max_depth, &key_converter)
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
                max_depth,
                &key_converter
              )
            end
          ensure
            visiting.delete(oid)
          end
        end

        def transform_value(value, visiting, depth, max_depth, &key_converter)
          case value
          when Hash
            transform_hash(value, visiting, depth, max_depth, &key_converter)
          when Array
            transform_array(value, visiting, depth, max_depth, &key_converter)
          else
            value
          end
        end

        private

        def check_depth!(depth, max_depth)
          return if max_depth.nil?

          raise StructureTooDeepError, "Keycase nesting exceeds max_depth (#{max_depth})" if depth > max_depth
        end
      end
    end
  end
end
