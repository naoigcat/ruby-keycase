# frozen_string_literal: true

RSpec.describe Keycase::Support::Tokenizer do
  describe ".words" do
    it "splits words by separators and case boundaries" do
      cases = [
        ["Some words", %w[Some words]],
        ["some--words_", %w[some words]],
        ["HTTPResponseCode", %w[HTTP Response Code]],
        ["DB2Connector", %w[DB2 Connector]],
        ["w3cMarkupValidation", %w[w3c Markup Validation]]
      ]

      cases.each do |value, words|
        expect(described_class.words(value)).to eq words
      end
    end
  end
end
