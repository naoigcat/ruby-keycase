# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def keep_existing_key?(memo, new_key, original_key, on_collision)
          return false unless memo.key?(new_key)

          if on_collision == :raise
            message = "Keycase detected a key collision: #{original_key.inspect} converted to " \
                      "#{new_key.inspect}, which already exists in the transformed structure"
            raise KeyCollisionError, message
          end

          on_collision == :keep_first
        end

        def resolve_on_collision!(options)
          mode = options.fetch(:on_collision, :raise)
          return mode if %i[raise overwrite keep_first].include?(mode)

          raise ArgumentError, "Keycase on_collision must be :raise, :overwrite, or :keep_first (got #{mode.inspect})"
        end
      end
    end
  end
end
