# frozen_string_literal: true

RSpec.describe Keycase::ScreamingSnakeCase do
  describe "module functions on Keycase (no refinement required)" do
    it "converts scalars and nested structures" do
      expect(Keycase.screaming_snake_case("Some-Words")).to eq "SOME_WORDS"
      expect(Keycase.with_screaming_snake_case_keys({ "some-key" => 1 })).to eq({ "SOME_KEY" => 1 })
    end
  end

  describe "refinements" do
    using described_class

    it "matches Keycase module functions for scalar and structure conversions" do
      string = "Some-Words"
      symbol = :Some_Words
      structure = { "some-key" => { nested_key: 1 } }

      expect(Keycase.screaming_snake_case(string)).to eq string.to_screaming_snake_case
      expect(Keycase.screaming_snake_case(symbol)).to eq symbol.to_screaming_snake_case
      expect(Keycase.with_screaming_snake_case_keys(structure)).to eq structure.with_screaming_snake_case_keys
    end

    it "convert strings" do
      expect("a".to_screaming_snake_case).to eq "A"
      expect("A".to_screaming_snake_case).to eq "A"
      expect("1".to_screaming_snake_case).to eq "1"
      expect("a1".to_screaming_snake_case).to eq "A1"
      expect("A1".to_screaming_snake_case).to eq "A1"
      expect("case".to_screaming_snake_case).to eq "CASE"
      expect("Case".to_screaming_snake_case).to eq "CASE"
      expect("CASE".to_screaming_snake_case).to eq "CASE"
      expect("Some words".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("Some Words".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("some-words".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("some--words_".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("SOME_WORDS".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("SOME__WORDS_".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("Some:words;".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("Some,words.".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("[Some|words]".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("someWords".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("SomeWords".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("HTML Generator".to_screaming_snake_case).to eq "HTML_GENERATOR"
      expect("HTTPResponseCode".to_screaming_snake_case).to eq "HTTP_RESPONSE_CODE"
      expect("DB2Connector".to_screaming_snake_case).to eq "DB2_CONNECTOR"
      expect("w3cMarkupValidation".to_screaming_snake_case).to eq "W3C_MARKUP_VALIDATION"
      expect("Some-Words".to_screaming_snake_case).to eq "SOME_WORDS"
      expect("Content-Type".to_screaming_snake_case).to eq "CONTENT_TYPE"
      expect("HTTP-Response-Code".to_screaming_snake_case).to eq "HTTP_RESPONSE_CODE"
      expect("Html-Generator".to_screaming_snake_case).to eq "HTML_GENERATOR"
      expect("Db2-Connector".to_screaming_snake_case).to eq "DB2_CONNECTOR"
      expect("W3c-Markup-Validation".to_screaming_snake_case).to eq "W3C_MARKUP_VALIDATION"
    end

    it "just returns numeric as is" do
      expect(1.to_screaming_snake_case).to eq 1
      expect(1.1.to_screaming_snake_case).to eq 1.1
    end

    it "converts symbol as string" do
      expect(:Symbol.to_screaming_snake_case).to eq :SYMBOL
      expect(:some_words.to_screaming_snake_case).to eq :SOME_WORDS
      expect(:"Some-Words".to_screaming_snake_case).to eq :SOME_WORDS
      expect(:"Content-Type".to_screaming_snake_case).to eq :CONTENT_TYPE
    end

    it "converts hash keys" do
      hash = {
        :symbol_key => "symbol value",
        "text_key" => "text value",
        :camelKey => "camel value",
        :PascalKey => "pascal value",
        "Content-Type" => "gzip",
        :"Some-Words" => "ok",
        "HTTP-Response-Code" => 418,
        "Nested-Train" => {
          "Inner-Key" => 1
        },
        :nested_hash => {
          :nested_symbol_key => "nested symbol value",
          "nested_text_key" => "nested text value",
          :nestedCamelKey => "nested camel value",
          :NestedPascalKey => "nested pascal value"
        },
        :nested_array => [
          { array_nested_hash_1: "nested value 1" },
          { array_nested_hash_2: "nested value 2" }
        ]
      }
      converted_hash = {
        :SYMBOL_KEY => "symbol value",
        "TEXT_KEY" => "text value",
        :CAMEL_KEY => "camel value",
        :PASCAL_KEY => "pascal value",
        "CONTENT_TYPE" => "gzip",
        SOME_WORDS: "ok",
        "HTTP_RESPONSE_CODE" => 418,
        "NESTED_TRAIN" => {
          "INNER_KEY" => 1
        },
        :NESTED_HASH => {
          :NESTED_SYMBOL_KEY => "nested symbol value",
          "NESTED_TEXT_KEY" => "nested text value",
          :NESTED_CAMEL_KEY => "nested camel value",
          :NESTED_PASCAL_KEY => "nested pascal value"
        },
        :NESTED_ARRAY => [
          { ARRAY_NESTED_HASH_1: "nested value 1" },
          { ARRAY_NESTED_HASH_2: "nested value 2" }
        ]
      }
      expect(hash.with_screaming_snake_case_keys).to eq converted_hash
    end
  end
end
