# frozen_string_literal: true

RSpec.describe Keycase::SnakeCase do
  using described_class
  it "convert strings" do
    expect("a".to_snake_case).to eq "a"
    expect("A".to_snake_case).to eq "a"
    expect("1".to_snake_case).to eq "1"
    expect("a1".to_snake_case).to eq "a1"
    expect("A1".to_snake_case).to eq "a1"
    expect("case".to_snake_case).to eq "case"
    expect("Case".to_snake_case).to eq "case"
    expect("CASE".to_snake_case).to eq "case"
    expect("Some words".to_snake_case).to eq "some_words"
    expect("Some Words".to_snake_case).to eq "some_words"
    expect("some-words".to_snake_case).to eq "some_words"
    expect("some--words_".to_snake_case).to eq "some_words"
    expect("SOME_WORDS".to_snake_case).to eq "some_words"
    expect("SOME__WORDS_".to_snake_case).to eq "some_words"
    expect("Some:words;".to_snake_case).to eq "some_words"
    expect("Some,words.".to_snake_case).to eq "some_words"
    expect("[Some|words]".to_snake_case).to eq "some_words"
    expect("someWords".to_snake_case).to eq "some_words"
    expect("SomeWords".to_snake_case).to eq "some_words"
    expect("HTML Generator".to_snake_case).to eq "html_generator"
    expect("HTTPResponseCode".to_snake_case).to eq "http_response_code"
    expect("DB2Connector".to_snake_case).to eq "db2_connector"
    expect("w3cMarkupValidation".to_snake_case).to eq "w3c_markup_validation"
    expect("Some-Words".to_snake_case).to eq "some_words"
    expect("Content-Type".to_snake_case).to eq "content_type"
    expect("HTTP-Response-Code".to_snake_case).to eq "http_response_code"
    expect("Html-Generator".to_snake_case).to eq "html_generator"
    expect("Db2-Connector".to_snake_case).to eq "db2_connector"
    expect("W3c-Markup-Validation".to_snake_case).to eq "w3c_markup_validation"
  end

  it "just returns numeric as is" do
    expect(1.to_snake_case).to eq 1
    expect(1.1.to_snake_case).to eq 1.1
  end

  it "converts symbol as string" do
    expect(:Symbol.to_snake_case).to eq :symbol
    expect(:someWords.to_snake_case).to eq :some_words
    expect(:"Some-Words".to_snake_case).to eq :some_words
    expect(:"Content-Type".to_snake_case).to eq :content_type
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
      :symbol_key => "symbol value",
      "text_key" => "text value",
      :camel_key => "camel value",
      :pascal_key => "pascal value",
      "content_type" => "gzip",
      some_words: "ok",
      "http_response_code" => 418,
      "nested_train" => {
        "inner_key" => 1
      },
      :nested_hash => {
        :nested_symbol_key => "nested symbol value",
        "nested_text_key" => "nested text value",
        :nested_camel_key => "nested camel value",
        :nested_pascal_key => "nested pascal value"
      },
      :nested_array => [
        { array_nested_hash_1: "nested value 1" },
        { array_nested_hash_2: "nested value 2" }
      ]
    }
    expect(hash.with_snake_case_keys).to eq converted_hash
  end
end
