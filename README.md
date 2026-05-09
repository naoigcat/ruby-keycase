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

## Interface

Keycase is provided as Ruby refinements. Enable the case conversion you want with `using`.

| Refinement | String/Symbol conversion | Hash/Array key conversion |
| --- | --- | --- |
| `Keycase::CamelCase` | `to_camel_case` | `with_camel_case_keys` |
| `Keycase::PascalCase` | `to_pascal_case` | `with_pascal_case_keys` |
| `Keycase::SnakeCase` | `to_snake_case` | `with_snake_case_keys` |
| `Keycase::ScreamingSnakeCase` | `to_screaming_snake_case` | `with_screaming_snake_case_keys` |
| `Keycase::KebabCase` | `to_kebab_case` | `with_kebab_case_keys` |
| `Keycase::TrainCase` | `to_train_case` | `with_train_case_keys` |

`String#to_*` returns a converted string. `Symbol#to_*` returns a converted symbol. Other objects respond to these methods and return themselves unchanged.

`Hash#with_*_keys` and `Array#with_*_keys` recursively convert only Hash keys.
Arrays are traversed so hashes inside arrays are converted. Values that are not Hash or Array objects are returned unchanged.
Key type is preserved: string keys remain strings, and symbol keys remain symbols.

```rb
using Keycase::SnakeCase

"userID".to_snake_case
# => "user_id"

:userID.to_snake_case
# => :user_id

[
  { "userID" => 1 },
  { :createdAt => "2026-05-09" },
].with_snake_case_keys
# => [
#   { "user_id" => 1 },
#   { :created_at => "2026-05-09" },
# ]
```

## Options

All `with_*_keys` methods accept an options hash.

| Option | Default | Description |
| --- | --- | --- |
| `max_depth` | `nil` | Maximum nested Hash/Array depth to traverse. `nil` means no depth limit. |

Depth starts at `0` for the receiver itself. Each nested Hash or Array increases
the depth by `1`. Leaf values are not counted.

```rb
using Keycase::CamelCase

{ user: { profile_data: { display_name: "Alice" } } }.with_camel_case_keys(max_depth: 2)
# => { :user => { :profileData => { :displayName => "Alice" } } }

{ user: { profile_data: { display_name: "Alice" } } }.with_camel_case_keys(max_depth: 1)
# raises Keycase::StructureTooDeepError
```

## Errors

`with_*_keys` raises Keycase-specific errors when recursive conversion cannot be completed without ambiguity or infinite traversal.

| Error | Raised when |
| --- | --- |
| `Keycase::CircularStructureError` | A Hash or Array references itself through the current traversal path. |
| `Keycase::KeyCollisionError` | Multiple source keys in the same Hash convert to the same destination key. |
| `Keycase::StructureTooDeepError` | Traversal exceeds the supplied `max_depth`. |

Circular references are rejected because recursive conversion could not finish.
Reusing the same non-circular object from multiple places is supported; each path is converted into a separate result object.

```rb
using Keycase::CamelCase

hash = {}
hash[:self_reference] = hash
hash.with_camel_case_keys
# raises Keycase::CircularStructureError
```

Key collisions are rejected so conversion never silently overwrites data. The check is performed per Hash after the keys are converted.

```rb
using Keycase::CamelCase

{ :user_id => 1, :userID => 2 }.with_camel_case_keys
# raises Keycase::KeyCollisionError
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests with the local Ruby version defined in `mise.toml` (currently Ruby 3.4.9). You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

Tasks are defined in `mise.toml`. They run **RuboCop, and RSpec inside Docker** (via Docker Compose), so Docker must be available. Use these tasks for syntax checks and tests across supported Ruby versions.

Run **RuboCop** on every supported Ruby image (2.3 through 4.0):

```sh
mise run -j 1 rubocop
```

Run **RSpec** the same way:

```sh
mise run -j 1 rspec
```

These commands execute the version-specific tasks in order (`rubocop23` … `rubocop40`, `rspec23` … `rspec40`). To run against a **single** Ruby version, use the matching task name, for example:

```sh
mise run rubocop34
mise run rspec34
```

To list all tasks and descriptions:

```sh
mise tasks
```

## Release Authentication

Gem releases from GitHub Actions use RubyGems Trusted Publishing. No long-lived RubyGems API key or GitHub secret is required; GitHub Actions obtains a short-lived RubyGems API token through OIDC during the release job.

Configure the trusted publisher once on RubyGems.org:

1.  Log in to <https://rubygems.org> with an owner account for the `keycase` gem.
2.  Open the [`keycase`](https://rubygems.org/gems/keycase) gem page and go to `Trusted publishers`.
3.  Create a GitHub Actions trusted publisher with these values:

    -   Repository owner: `naoigcat`
    -   Repository name: `ruby-keycase`
    -   Workflow filename: `release.yml`
    -   Environment name: `release`

After this setup, run the `Release Gem` workflow manually from GitHub Actions. Enter the version already committed in `lib/keycase/version.rb`; the workflow verifies the version, creates the `v<version>` tag through Bundler's release task, and publishes the gem to RubyGems.org.

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/naoigcat/ruby-keycase>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
