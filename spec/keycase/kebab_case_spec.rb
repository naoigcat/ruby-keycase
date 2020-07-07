RSpec.describe Keycase::KebabCase do
  using Keycase::KebabCase
  it "convert strings" do
    expect("a".to_kebab_case).to eq "a"
    expect("A".to_kebab_case).to eq "a"
    expect("1".to_kebab_case).to eq "1"
    expect("a1".to_kebab_case).to eq "a1"
    expect("A1".to_kebab_case).to eq "a1"
    expect("case".to_kebab_case).to eq "case"
    expect("Case".to_kebab_case).to eq "case"
    expect("CASE".to_kebab_case).to eq "case"
    expect("Some words".to_kebab_case).to eq "some-words"
    expect("Some Words".to_kebab_case).to eq "some-words"
    expect("some-words".to_kebab_case).to eq "some-words"
    expect("some--words_".to_kebab_case).to eq "some-words"
    expect("SOME_WORDS".to_kebab_case).to eq "some-words"
    expect("SOME__WORDS_".to_kebab_case).to eq "some-words"
    expect("Some:words;".to_kebab_case).to eq "some-words"
    expect("Some,words.".to_kebab_case).to eq "some-words"
    expect("[Some|words]".to_kebab_case).to eq "some-words"
    expect("someWords".to_kebab_case).to eq "some-words"
    expect("SomeWords".to_kebab_case).to eq "some-words"
    expect("HTML Generator".to_kebab_case).to eq "html-generator"
    expect("DB2Connector".to_kebab_case).to eq "db2-connector"
    expect("w3cMarkupValidation".to_kebab_case).to eq "w3c-markup-validation"
  end
  it "just returns numeric as is" do
    expect(1.to_kebab_case).to eq 1
    expect(1.1.to_kebab_case).to eq 1.1
  end
  it "converts symbol as string" do
    expect(:Symbol.to_kebab_case).to eq :symbol
    expect(:some_words.to_kebab_case).to eq :"some-words"
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
      :"symbol-key" => "symbol value",
      "text-key" => "text value",
      :"camel-key" => "camel value",
      :"pascal-key" => "pascal value",
      :"nested-hash" => {
        :"nested-symbol-key" => "nested symbol value",
        "nested-text-key" => "nested text value",
        :"nested-camel-key" => "nested camel value",
        :"nested-pascal-key" => "nested pascal value",
      },
      :"nested-array" => [
        { :"array-nested-hash-1" => "nested value 1" },
        { :"array-nested-hash-2" => "nested value 2" },
      ],
    }
    expect(hash.with_kebab_case_keys).to eq converted_hash
  end
end
