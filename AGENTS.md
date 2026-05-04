# AGENTS.md

## Ruby blocks

Always write blocks with **`do` / `end`**, never curly braces (`{ |x| ... }`), including single-line blocks. Ignore formatter defaults that rewrite blocks to braces.

The only exception is **RSpec `expect`**: use the brace form for the block passed to `expect` (for example `expect { ... }.to`, `expect { ... }.not_to`, `expect { ... }.to raise_error`) so matchers and change-detection idioms work as intended.
