# frozen_string_literal: true

# Recursively converts string/symbol case and hash keys (camelCase, snake_case, etc.).
#
# Call module functions on the +Keycase+ module (for example +Keycase.camel_case+,
# +Keycase.with_camel_case_keys+) when +using Keycase::CamelCase+ (or another case
# module) is impractical, such as in a Rails initializer, another gem, or shared code.
# Refinements remain available for lexically scoped +to_*+ / +with_*_keys+ instance methods.
require "keycase/version"
require "keycase/support/errors"
require "keycase/support/transformer"
require "keycase/support/tokenizer"
require "keycase/camel_case"
require "keycase/kebab_case"
require "keycase/pascal_case"
require "keycase/screaming_snake_case"
require "keycase/snake_case"
require "keycase/train_case"

module Keycase
end
