# frozen_string_literal: true

RSpec.describe Keycase::CamelCase do
  using described_class
  it "convert strings" do
    expect("a".to_camel_case).to eq "a"
    expect("A".to_camel_case).to eq "a"
    expect("1".to_camel_case).to eq "1"
    expect("a1".to_camel_case).to eq "a1"
    expect("A1".to_camel_case).to eq "a1"
    expect("case".to_camel_case).to eq "case"
    expect("Case".to_camel_case).to eq "case"
    expect("CASE".to_camel_case).to eq "case"
    expect("Some words".to_camel_case).to eq "someWords"
    expect("Some Words".to_camel_case).to eq "someWords"
    expect("some-words".to_camel_case).to eq "someWords"
    expect("some--words_".to_camel_case).to eq "someWords"
    expect("SOME_WORDS".to_camel_case).to eq "someWords"
    expect("SOME__WORDS_".to_camel_case).to eq "someWords"
    expect("Some:words;".to_camel_case).to eq "someWords"
    expect("Some,words.".to_camel_case).to eq "someWords"
    expect("[Some|words]".to_camel_case).to eq "someWords"
    expect("someWords".to_camel_case).to eq "someWords"
    expect("SomeWords".to_camel_case).to eq "someWords"
    expect("HTML Generator".to_camel_case).to eq "htmlGenerator"
    expect("DB2Connector".to_camel_case).to eq "db2Connector"
    expect("w3cMarkupValidation".to_camel_case).to eq "w3cMarkupValidation"
  end

  it "just returns numeric as is" do
    expect(1.to_camel_case).to eq 1
    expect(1.1.to_camel_case).to eq 1.1
  end

  it "converts symbol as string" do
    expect(:Symbol.to_camel_case).to eq :symbol
    expect(:some_words.to_camel_case).to eq :someWords
  end

  it "converts hash keys" do
    hash = {
      :symbol_key => "symbol value",
      "text_key" => "text value",
      :camelKey => "camel value",
      :PascalKey => "pascal value",
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
      :symbolKey => "symbol value",
      "textKey" => "text value",
      :camelKey => "camel value",
      :pascalKey => "pascal value",
      :nestedHash => {
        :nestedSymbolKey => "nested symbol value",
        "nestedTextKey" => "nested text value",
        :nestedCamelKey => "nested camel value",
        :nestedPascalKey => "nested pascal value"
      },
      :nestedArray => [
        { arrayNestedHash1: "nested value 1" },
        { arrayNestedHash2: "nested value 2" }
      ]
    }
    expect(hash.with_camel_case_keys).to eq converted_hash
  end
end
