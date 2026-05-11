# frozen_string_literal: true

RSpec.describe Keycase::PascalCase do
  describe "module functions on Keycase (no refinement required)" do
    it "converts scalars and nested structures" do
      expect(Keycase.pascal_case("Some-Words")).to eq "SomeWords"
      expect(Keycase.with_pascal_case_keys({ "some-key" => { nested_key: 1 } })).to eq(
        { "SomeKey" => { NestedKey: 1 } }
      )
    end
  end

  describe "refinements" do
    using described_class

    it "matches Keycase module functions for scalar and structure conversions" do
      string = "Some-Words"
      symbol = :Some_Words
      structure = { "some-key" => { nested_key: 1 } }

      expect(Keycase.pascal_case(string)).to eq string.to_pascal_case
      expect(Keycase.pascal_case(symbol)).to eq symbol.to_pascal_case
      expect(Keycase.with_pascal_case_keys(structure)).to eq structure.with_pascal_case_keys
    end

    it "convert strings" do
      expect("a".to_pascal_case).to eq "A"
      expect("A".to_pascal_case).to eq "A"
      expect("1".to_pascal_case).to eq "1"
      expect("a1".to_pascal_case).to eq "A1"
      expect("A1".to_pascal_case).to eq "A1"
      expect("case".to_pascal_case).to eq "Case"
      expect("Case".to_pascal_case).to eq "Case"
      expect("CASE".to_pascal_case).to eq "Case"
      expect("Some words".to_pascal_case).to eq "SomeWords"
      expect("Some Words".to_pascal_case).to eq "SomeWords"
      expect("some-words".to_pascal_case).to eq "SomeWords"
      expect("some--words_".to_pascal_case).to eq "SomeWords"
      expect("SOME_WORDS".to_pascal_case).to eq "SomeWords"
      expect("SOME__WORDS_".to_pascal_case).to eq "SomeWords"
      expect("Some:words;".to_pascal_case).to eq "SomeWords"
      expect("Some,words.".to_pascal_case).to eq "SomeWords"
      expect("[Some|words]".to_pascal_case).to eq "SomeWords"
      expect("someWords".to_pascal_case).to eq "SomeWords"
      expect("SomeWords".to_pascal_case).to eq "SomeWords"
      expect("HTML Generator".to_pascal_case).to eq "HtmlGenerator"
      expect("APIResponse".to_pascal_case).to eq "ApiResponse"
      expect("DB2Connector".to_pascal_case).to eq "Db2Connector"
      expect("w3cMarkupValidation".to_pascal_case).to eq "W3cMarkupValidation"
      expect("Some-Words".to_pascal_case).to eq "SomeWords"
      expect("Content-Type".to_pascal_case).to eq "ContentType"
      expect("HTTP-Response-Code".to_pascal_case).to eq "HttpResponseCode"
      expect("Html-Generator".to_pascal_case).to eq "HtmlGenerator"
      expect("Db2-Connector".to_pascal_case).to eq "Db2Connector"
      expect("W3c-Markup-Validation".to_pascal_case).to eq "W3cMarkupValidation"
    end

    it "just returns numeric as is" do
      expect(1.to_pascal_case).to eq 1
      expect(1.1.to_pascal_case).to eq 1.1
    end

    it "converts symbol as string" do
      expect(:Symbol.to_pascal_case).to eq :Symbol
      expect(:some_words.to_pascal_case).to eq :SomeWords
      expect(:"Some-Words".to_pascal_case).to eq :SomeWords
      expect(:"Content-Type".to_pascal_case).to eq :ContentType
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
        :SymbolKey => "symbol value",
        "TextKey" => "text value",
        :CamelKey => "camel value",
        :PascalKey => "pascal value",
        "ContentType" => "gzip",
        SomeWords: "ok",
        "HttpResponseCode" => 418,
        "NestedTrain" => {
          "InnerKey" => 1
        },
        :NestedHash => {
          :NestedSymbolKey => "nested symbol value",
          "NestedTextKey" => "nested text value",
          :NestedCamelKey => "nested camel value",
          :NestedPascalKey => "nested pascal value"
        },
        :NestedArray => [
          { ArrayNestedHash1: "nested value 1" },
          { ArrayNestedHash2: "nested value 2" }
        ]
      }
      expect(hash.with_pascal_case_keys).to eq converted_hash
    end
  end
end
