# frozen_string_literal: true

require "set"

require_relative "transformer"

module Keycase
  module Support
    module StructureKeys
      module_function

      def transform(structure, options = {}, &key_converter)
        opts = Transformer.enrich_options(options)

        case structure
        when Hash
          state = Transformer::State.new(::Set.new, 0, opts, :none)
          Transformer.transform_hash(structure, state, &key_converter)
        when Array
          state = Transformer::State.new(::Set.new, 0, opts, :none)
          Transformer.transform_array(structure, state, &key_converter)
        else
          structure
        end
      end
    end
  end
end
