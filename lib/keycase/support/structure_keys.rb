# frozen_string_literal: true

require "set"

require_relative "transformer"

module Keycase
  module Support
    module StructureKeys
      module_function

      def transform(structure, options = {}, &key_converter)
        case structure
        when Hash
          Transformer.transform_hash(
            structure,
            ::Set.new,
            0,
            options[:max_depth],
            &key_converter
          )
        when Array
          Transformer.transform_array(
            structure,
            ::Set.new,
            0,
            options[:max_depth],
            &key_converter
          )
        else
          structure
        end
      end
    end
  end
end
