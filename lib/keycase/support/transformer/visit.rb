# frozen_string_literal: true

module Keycase
  module Support
    module Transformer
      class << self
        private

        def visit_structure(structure, visiting, kind)
          oid = structure.object_id
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
