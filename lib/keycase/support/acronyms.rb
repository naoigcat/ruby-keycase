# frozen_string_literal: true

module Keycase
  module Support
    module Acronyms
      module_function

      def index(list)
        return {} if list.nil?

        Array(list).each_with_object({}) do |item, memo|
          s = item.to_s
          next if s.empty?

          memo[s.downcase] = s
        end
      end

      def segment(word, acronyms_by_downcase)
        acronyms_by_downcase[word.downcase] || word.capitalize
      end

      def leading_acronym?(first_word, acronyms_by_downcase)
        return false unless first_word

        acronyms_by_downcase.key?(first_word.downcase)
      end
    end
  end
end
