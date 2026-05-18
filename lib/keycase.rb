# frozen_string_literal: true

# Recursively converts string/symbol case and hash keys (camelCase, snake_case, etc.).
#
# +Keycase+ is reopened in +lib/keycase/<case>.rb+; module functions (+Keycase.camel_case+ and
# friends) and refinement modules (+Keycase::CamelCase+, ...) live in those files, not here.
#
# Call module functions on +Keycase+ when +using Keycase::CamelCase+ (or another case module)
# is impractical, such as in a Rails initializer, another gem, or shared code. Refinements remain
# available for lexically scoped +to_*+ / +with_*_keys+ instance methods.
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
