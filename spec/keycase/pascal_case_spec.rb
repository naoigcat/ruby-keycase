RSpec.describe Keycase::PascalCase do
  using Keycase::PascalCase
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
    expect("DB2Connector".to_pascal_case).to eq "Db2Connector"
    expect("w3cMarkupValidation".to_pascal_case).to eq "W3cMarkupValidation"
  end
  it "just returns numeric as is" do
    expect(1.to_pascal_case).to eq 1
    expect(1.1.to_pascal_case).to eq 1.1
  end
  it "converts symbol as string" do
    expect(:Symbol.to_pascal_case).to eq :Symbol
    expect(:some_words.to_pascal_case).to eq :SomeWords
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
        :NestedPascalKey => "nested pascal value",
      },
      :nested_array => [
        { :array_nested_hash_1 => "nested value 1" },
        { :array_nested_hash_2 => "nested value 2" },
      ],
    }
    converted_hash = {
      :SymbolKey => "symbol value",
      "TextKey" => "text value",
      :CamelKey => "camel value",
      :PascalKey => "pascal value",
      :NestedHash => {
        :NestedSymbolKey => "nested symbol value",
        "NestedTextKey" => "nested text value",
        :NestedCamelKey => "nested camel value",
        :NestedPascalKey => "nested pascal value",
      },
      :NestedArray => [
        { :ArrayNestedHash1 => "nested value 1" },
        { :ArrayNestedHash2 => "nested value 2" },
      ],
    }
    expect(hash.with_pascal_case_keys).to eq converted_hash
  end
end
