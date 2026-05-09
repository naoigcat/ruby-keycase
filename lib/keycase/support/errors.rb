# frozen_string_literal: true

module Keycase
  # Signals that recursive key conversion cannot finish because the input graph loops.
  class CircularStructureError < StandardError; end

  # Signals that conversion would overwrite data by mapping multiple source keys to one key.
  class KeyCollisionError < StandardError; end

  # Signals that the caller's depth limit rejected input that is too deeply nested.
  class StructureTooDeepError < StandardError; end
end
