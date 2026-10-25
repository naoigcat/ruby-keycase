# frozen_string_literal: true

require "set"

require_relative "transformer"

module Keycase
  module Support
    module StructureKeys
      module_function

      def transform(structure, options = {}, &key_converter)
        opts = Transformer.enrich_options(options)
        state = Transformer::State.new(::Set.new, 0, opts, :none)

        Transformer.transform_value(structure, state, &key_converter)
      end
    end
  end
end
