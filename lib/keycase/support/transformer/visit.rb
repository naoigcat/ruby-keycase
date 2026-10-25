# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def check_depth!(depth, max_depth)
          return if max_depth.nil?

          raise StructureTooDeepError, "Keycase nesting exceeds max_depth (#{max_depth})" if depth > max_depth
        end

        def visit_structure(structure, visiting, kind)
          oid = Object.instance_method(:object_id).bind(structure).call
          raise CircularStructureError, circular_reference_message(kind) if visiting.include?(oid)

          visiting.add(oid)
          begin
            yield
          ensure
            visiting.delete(oid)
          end
        end

        def circular_reference_message(kind)
          "Keycase detected a circular reference in a #{kind}"
        end
      end
    end
  end
end
