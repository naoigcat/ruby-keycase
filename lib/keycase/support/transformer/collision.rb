# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def resolve_member_key_collision!(on_collision, collision_details, &key_converter)
          case on_collision
          when :raise
            message = "Keycase detected a key collision: #{collision_details.original_key.inspect} converted to " \
                      "#{collision_details.new_key.inspect}, which already exists in the transformed structure"
            raise KeyCollisionError, message
          when :overwrite
            d = collision_details
            d.memo[d.new_key] = transform_value(d.value, d.child_state, &key_converter)
          when :keep_first
            nil
          end
        end

        def resolve_hash_key_collision!(on_collision, collision_details, &key_converter)
          resolve_member_key_collision!(on_collision, collision_details, &key_converter)
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

        def convert_key?(key, options)
          klasses = options[:__keycase_only_klasses]
          return true if klasses.nil?

          klasses.any? do |klass|
            key.is_a?(klass)
          end
        end
      end
    end
  end
end
