# Keycase

This gem converts the case of strings, symbols, and keys of hash recursively.
The convertible cases are camelCase, PascalCase, snake_case, SCREAMING_SNAKE_CASE, kebab-case, and Train-Case.

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

### Module functions (no `using`)

Call methods on `Keycase` when refinements are awkward (Rails, other gems, shared libraries).

```rb
require "keycase"

Keycase.camel_case("user_id")          # => "userId"
Keycase.camel_case(:user_id)          # => :userId
Keycase.camel_case(42)                 # => 42

Keycase.camel_case("APIResponse", acronyms: %w[API HTTP ID])
# => "APIResponse"

Keycase.camel_case("user_id", capitalize: true)
# => "UserId"

Keycase.snake_case("userID", upcase: true)
# => "USER_ID"

Keycase.kebab_case("user_id", capitalize: true)
# => "User-Id"

Keycase.with_camel_case_keys({ "user_id" => 1, nested: { "item_count" => 2 } })
# => { "userId" => 1, :nested => { "itemCount" => 2 } }

Keycase.with_camel_case_keys(
  { "API-Key" => 1, nested: { "http_status" => 200 } },
  acronyms: %w[API HTTP],
)
# => { "APIKey" => 1, :nested => { "httpStatus" => 200 } }
```

See [Interface](#interface) for the full list of `Keycase.*` methods and their refinement equivalents.

### Refinements

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

Keycase offers **module functions** on `Keycase` (no `using` required) and the same behavior as **refinements** when you `using Keycase::CamelCase` (and similarly for other case modules).

| Refinement | `Keycase` module function (scalar) | `Keycase` module function (Hash/Array keys) | Refinement instance methods |
| --- | --- | --- | --- |
| `Keycase::CamelCase` | `Keycase.camel_case` | `Keycase.with_camel_case_keys` | `to_camel_case` / `with_camel_case_keys` |
| `Keycase::SnakeCase` | `Keycase.snake_case` | `Keycase.with_snake_case_keys` | `to_snake_case` / `with_snake_case_keys` |
| `Keycase::KebabCase` | `Keycase.kebab_case` | `Keycase.with_kebab_case_keys` | `to_kebab_case` / `with_kebab_case_keys` |

`Keycase.camel_case` (and the other `Keycase.*` scalar methods) behave like refinement `to_*` for strings and symbols, and leave other objects unchanged.

Use options to select the former paired case variants:

-   `Keycase.camel_case(..., capitalize: true)` converts to PascalCase.
-   `Keycase.snake_case(..., upcase: true)` converts to SCREAMING_SNAKE_CASE.
-   `Keycase.kebab_case(..., capitalize: true)` converts to Train-Case.

For **camelCase**, **PascalCase**, and **Train-Case** you can pass [`acronyms`](#acronyms-initialisms) so tokens such as `API`, `HTTP`, or `ID` keep the spelling you configure instead of being title-cased (for example `Api`, `Http`). Other case styles are unchanged by this option.

`Keycase.with_camel_case_keys` (and siblings) behave like `Hash#with_*_keys` and `Array#with_*_keys` after the matching `using`.

`String#to_*` returns a converted string. `Symbol#to_*` returns a converted symbol. Other objects respond to these refinement-only methods by returning themselves unchanged.

`Hash#with_*_keys`, `Array#with_*_keys`, and `Struct#with_*_keys` recursively convert keys by default.
Arrays are traversed so hashes and structs inside arrays are converted. Other values are returned unchanged.
Key type is preserved: string keys remain strings, and symbol keys remain symbols.
Optional [`recursive`](#traversal-scope-recursive-arrays), [`arrays`](#traversal-scope-recursive-arrays), and [`only`](#key-types-only) narrow **what** is traversed and **which** keys are converted.

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

All structure key conversion methods (`Keycase.with_*_keys`, and `Hash#with_*_keys` / `Array#with_*_keys` after `using`) accept an options hash.

| Option | Default | Description |
| --- | --- | --- |
| `max_depth` | `nil` | Maximum nested Hash/Array/Struct depth to traverse. `nil` means no depth limit. |
| `on_collision` | `:raise` | How to handle multiple source keys that convert to the same destination key in one Hash. See [Key collisions (`on_collision`)](#key-collisions-on_collision). |
| `recursive` | `true` | When `false`, hashes nested **under another hash** are not converted (see [Traversal scope](#traversal-scope-recursive-arrays)). |
| `arrays` | `true` | When `false`, array elements are not traversed (see [Traversal scope](#traversal-scope-recursive-arrays)). |
| `only` | `nil` | Restrict conversion to certain key types (`:string`, `:symbol`, or `String` / `Symbol`). See [Key types (`only`)](#key-types-only). |
| `acronyms` | `nil` | For `camel_case` and capitalized `kebab_case` key conversion only: list of strings treated as initialisms. See [Acronyms](#acronyms-initialisms). |
| `capitalize` | `false` | For `camel_case`, converts to PascalCase. For `kebab_case`, converts to Train-Case. |
| `upcase` | `false` | For `snake_case`, converts to SCREAMING_SNAKE_CASE. |

Depth starts at `0` for the receiver itself. Each nested Hash, Array, or Struct increases
the depth by `1`. Leaf values are not counted.

```rb
using Keycase::CamelCase

{ user: { profile_data: { display_name: "Alice" } } }.with_camel_case_keys(max_depth: 2)
# => { :user => { :profileData => { :displayName => "Alice" } } }

{ user: { profile_data: { display_name: "Alice" } } }.with_camel_case_keys(max_depth: 1)
# raises Keycase::StructureTooDeepError
```

### Traversal scope (`recursive`, `arrays`)

Use these when you want shallow conversion (for example only the outer hash or skipping arrays) without relying on `max_depth` alone.

-   **`recursive`:** With `false`, **only hashes nested as values of another hash** are left untouched—same object as in the input for those inner hashes. Hashes that appear **as array elements** are still converted by default, because their parent is an Array, not a Hash.

    ```rb
    using Keycase::CamelCase

    { outer_key: { inner_key: 1 } }.with_camel_case_keys(recursive: false)
    # => { :outerKey => { :inner_key => 1 } }

    { items: [{ nested_key: 1 }] }.with_camel_case_keys(recursive: false)
    # => { :items => [{ :nestedKey => 1 }] }
    ```

-   **`arrays`:** With `false`, arrays are not walked: elements stay as-is inside a new outer Array.

    ```rb
    { items: [{ nested_key: 1 }] }.with_camel_case_keys(arrays: false)
    # => { :items => [{ :nested_key => 1 }] }
    ```

Combine both for “top-level hash keys only” when values include nested hashes and arrays you do not want to reshape:

```rb
payload = { user_profile: { display_name: "Ada" }, tags: [{ tag_name: "ruby" }] }

payload.with_camel_case_keys(recursive: false, arrays: false)
# => { :userProfile => { :display_name => "Ada" }, :tags => [{ :tag_name => "ruby" }] }
```

`recursive` and `arrays` must be exactly `true` or `false`; other values raise `ArgumentError`.

With `recursive: false`, **structs nested as members of another struct** are left untouched—the same object as in the input—mirroring hash-under-hash behavior. Structs inside hashes or arrays are still converted.

### Structs

`Struct` member names are converted like hash keys. Nested hashes and arrays inside struct members are traversed by default.

```rb
using Keycase::CamelCase

Point = Struct.new(:foo_bar, :nested_hash, keyword_init: true)
point = Point.new(foo_bar: 1, nested_hash: { inner_key: 2 })

point.with_camel_case_keys
# => #<struct fooBar=1, nestedHash={ innerKey: 2 }>
```

When member names change, a new anonymous `Struct` class is built (custom `Struct` subclasses are not preserved after rename).

### Key types (`only`)

Pass `only:` as an array of `:string`, `:symbol`, and/or the classes `String` and `Symbol`. Only matching keys are passed through the case converter; other keys stay unchanged (same object).

Omit the option or pass `nil` for the usual behavior (string and symbol keys are converted). An **empty array** converts **no** keys.

```rb
using Keycase::CamelCase

{ "foo_bar" => 1, baz_qux: 2 }.with_camel_case_keys(only: [:string])
# => { "fooBar" => 1, :baz_qux => 2 }

{ "foo_bar" => 1, baz_qux: 2 }.with_camel_case_keys(only: [:symbol])
# => { "foo_bar" => 1, :bazQux => 2 }
```

Unsupported entries or a non-Array `only:` raise `ArgumentError`.

### Key collisions (`on_collision`)

By default, if two keys in the same Hash map to the same key after conversion, Keycase raises `Keycase::KeyCollisionError` so data is never dropped without you noticing. For migrations or log shaping you can pick another strategy:

| `on_collision` | Behavior |
| --- | --- |
| `:raise` | **Default.** Raise `Keycase::KeyCollisionError`. |
| `:overwrite` | Keep the **last** entry in Ruby Hash iteration order (insertion order) for that destination key. |
| `:keep_first` | Keep the **first** entry; later colliding keys are ignored (their values are not traversed). |

Unknown values raise `ArgumentError`. The option applies **per Hash** at each nesting level.

```rb
using Keycase::CamelCase

h = { :user_id => 1, :userID => 2 }

h.with_camel_case_keys
# raises Keycase::KeyCollisionError

h.with_camel_case_keys(on_collision: :overwrite)
# => { :userId => 2 }

h.with_camel_case_keys(on_collision: :keep_first)
# => { :userId => 1 }

Keycase.with_snake_case_keys({ "SomeKey" => 1, someKey: 2 }, on_collision: :keep_first)
# => { "some_key" => 1 }
```

### Acronyms (initialisms)

Use `acronyms` when you want multi-letter abbreviations to stay as you spell them (for example `API` instead of `Api`) after splitting a name into words.

Where it applies:

-   `Keycase.camel_case` and `Keycase.kebab_case(..., capitalize: true)` accept a keyword: `acronyms:`.
-   `Keycase.with_camel_case_keys` and `Keycase.with_kebab_case_keys(..., capitalize: true)` accept `acronyms:` in their **options hash** alongside `max_depth`, `on_collision`, `recursive`, `arrays`, and `only`.

Pass an array of strings. Matching is **case-insensitive** per word; the output uses the string from the array (the last occurrence wins if the same word appears twice with different casing). `nil` or omitting the option keeps the previous behavior.

**camelCase** lowercases the first character of the full name only when the **first** word is *not* one of the configured acronyms. That way `APIResponse` can stay `APIResponse`, while `myHTTPConnection` becomes `myHTTPConnection`.

**PascalCase** and **Train-Case** are selected with `capitalize: true`; they replace each matching word with the acronym spelling and title-Case other words as before.

snake_case, SCREAMING_SNAKE, and kebab_case do not use `acronyms`; they still normalize segments with `downcase` / `upcase` as usual.

```rb
abbr = %w[API HTTP ID]

Keycase.camel_case("APIResponse", acronyms: abbr)           # => "APIResponse"
Keycase.camel_case("HTTPResponseCode", acronyms: abbr, capitalize: true)
# => "HTTPResponseCode"
Keycase.kebab_case("HTTP-Response-Code", acronyms: abbr, capitalize: true)
# => "HTTP-Response-Code"

using Keycase::CamelCase
"userID".to_camel_case(acronyms: abbr)                      # => "userID"

Keycase.with_camel_case_keys({ "api_key" => 1 }, acronyms: abbr, capitalize: true)
# => { "APIKey" => 1 }
```

### Word splitting and character sets

Keycase splits names into words with `Keycase::Support::Tokenizer`, which collects runs of
**Unicode letters and numbers** (`\p{L}`, `\p{N}`) and inserts boundaries at common case
transitions in scripts that distinguish letter case (for example `userID` → `user`, `ID`;
`HTTPResponse` → `HTTP`, `Response`). Separators such as `-` and `_` between those runs are not
preserved as characters—only the letter and number pieces become words (for example
`API-Key` → `API`, `Key`; `ユーザー-user_id` → `ユーザー`, `user`, `id`).

**Characters outside `\p{L}` and `\p{N}`**—punctuation, symbols, emoji, and most whitespace—act as
separators and are not included in tokens. Scripts without cased letters (for example CJK) form a
single letter run unless you separate them with `-`, `_`, or similar. Mixed-script keys glued
without separators (for example Latin camelCase next to CJK text) are not split at the script
boundary.

Multilingual **Rails `I18n`** key paths that rely on punctuation or non-alphanumeric characters can
still behave unexpectedly after conversion, or make separate keys collide after conversion
(**`KeyCollisionError`** by default, or use [`on_collision`](#key-collisions-on_collision) to
overwrite or keep the first key) when you bulk-convert hashes.

## Errors

`Keycase.with_*_keys` and refinement `with_*_keys` raise Keycase-specific errors when recursive conversion cannot be completed without ambiguity or infinite traversal.

| Error | Raised when |
| --- | --- |
| `Keycase::CircularStructureError` | A Hash, Array, or Struct references itself through the current traversal path. |
| `Keycase::KeyCollisionError` | Multiple source keys in the same Hash convert to the same destination key and `on_collision` is `:raise` (the default). |
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

`Keycase::KeyCollisionError` is documented with examples under [Key collisions (`on_collision`)](#key-collisions-on_collision).

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
