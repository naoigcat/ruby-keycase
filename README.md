# Keycase

This gem converts the case of strings, symbols, and keys of hash recursively.
The convertible cases are camelCase, PascalCase, snake_case, etc.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "keycase"
```

And then execute:

  $ bundle install

Or install it yourself as:

  $ gem install keycase

## Usage

```sh
irb --context-mode=1
```

```rb
> require "bundler/setup"
> require "keycase"
> using Keycase::CamelCase
> hash = {
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
> hash.with_camel_case_keys
=> {
  :symbolKey => "symbol value",
  "textKey" => "text value",
  :camelKey => "camel value",
  :pascalKey => "pascal value",
  :nestedHash => {
    :nestedSymbolKey => "nested symbol value",
    "nestedTextKey" => "nested text value",
    :nestedCamelKey => "nested camel value",
    :nestedPascalKey => "nested pascal value",
  },
  :nestedArray => [
    { :arrayNestedHash1 => "nested value 1" },
    { :arrayNestedHash2 => "nested value 2" },
  ],
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/naoigcat/ruby-keycase>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
