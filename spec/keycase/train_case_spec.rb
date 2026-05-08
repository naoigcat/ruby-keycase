# frozen_string_literal: true

RSpec.describe Keycase::TrainCase do
  using described_class
  it "convert strings" do
    expect("a".to_train_case).to eq "A"
    expect("A".to_train_case).to eq "A"
    expect("1".to_train_case).to eq "1"
    expect("a1".to_train_case).to eq "A1"
    expect("A1".to_train_case).to eq "A1"
    expect("case".to_train_case).to eq "Case"
    expect("Case".to_train_case).to eq "Case"
    expect("CASE".to_train_case).to eq "Case"
    expect("Some words".to_train_case).to eq "Some-Words"
    expect("Some Words".to_train_case).to eq "Some-Words"
    expect("some-words".to_train_case).to eq "Some-Words"
    expect("some--words_".to_train_case).to eq "Some-Words"
    expect("SOME_WORDS".to_train_case).to eq "Some-Words"
    expect("SOME__WORDS_".to_train_case).to eq "Some-Words"
    expect("Some:words;".to_train_case).to eq "Some-Words"
    expect("Some,words.".to_train_case).to eq "Some-Words"
    expect("[Some|words]".to_train_case).to eq "Some-Words"
    expect("someWords".to_train_case).to eq "Some-Words"
    expect("SomeWords".to_train_case).to eq "Some-Words"
    expect("HTML Generator".to_train_case).to eq "Html-Generator"
    expect("HTTPResponseCode".to_train_case).to eq "Http-Response-Code"
    expect("DB2Connector".to_train_case).to eq "Db2-Connector"
    expect("w3cMarkupValidation".to_train_case).to eq "W3c-Markup-Validation"
    expect("Some-Words".to_train_case).to eq "Some-Words"
    expect("CONTENT-TYPE".to_train_case).to eq "Content-Type"
    expect("Content-Type".to_train_case).to eq "Content-Type"
    expect("HTTP-Response-Code".to_train_case).to eq "Http-Response-Code"
    expect("http-response-code".to_train_case).to eq "Http-Response-Code"
    expect("Html-Generator".to_train_case).to eq "Html-Generator"
    expect("Db2-Connector".to_train_case).to eq "Db2-Connector"
    expect("W3c-Markup-Validation".to_train_case).to eq "W3c-Markup-Validation"
  end

  it "just returns numeric as is" do
    expect(1.to_train_case).to eq 1
    expect(1.1.to_train_case).to eq 1.1
  end

  it "converts symbol as string" do
    expect(:Symbol.to_train_case).to eq :Symbol
    expect(:some_words.to_train_case).to eq :"Some-Words"
    expect(:"content-type".to_train_case).to eq :"Content-Type"
    expect(:"Some-Words".to_train_case).to eq :"Some-Words"
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
      :"Symbol-Key" => "symbol value",
      "Text-Key" => "text value",
      :"Camel-Key" => "camel value",
      :"Pascal-Key" => "pascal value",
      "Content-Type" => "gzip",
      "Some-Words": "ok",
      "Http-Response-Code" => 418,
      "Nested-Train" => {
        "Inner-Key" => 1
      },
      :"Nested-Hash" => {
        :"Nested-Symbol-Key" => "nested symbol value",
        "Nested-Text-Key" => "nested text value",
        :"Nested-Camel-Key" => "nested camel value",
        :"Nested-Pascal-Key" => "nested pascal value"
      },
      :"Nested-Array" => [
        { "Array-Nested-Hash-1": "nested value 1" },
        { "Array-Nested-Hash-2": "nested value 2" }
      ]
    }
    expect(hash.with_train_case_keys).to eq converted_hash
  end
end
