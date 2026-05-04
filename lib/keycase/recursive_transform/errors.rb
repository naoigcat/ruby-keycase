# frozen_string_literal: true

module Keycase
  class CircularStructureError < StandardError; end

  class KeyCollisionError < StandardError; end

  class StructureTooDeepError < StandardError; end
end
