require_relative "lib/keycase/version"

Gem::Specification.new do |spec|
  spec.name                   = "keycase"
  spec.version                = Keycase::VERSION
  spec.authors                = ["naoigcat"]
  spec.email                  = ["17925623+naoigcat@users.noreply.github.com"]

  spec.summary                = "Converts the case of strings, symbols, and keys of hash."
  spec.description            = <<~DESCRIPTION
    This gem converts the case of strings, symbols, and keys of hash recursively.
    The convertible cases are camelCase, PascalCase, snake_case, etc.
  DESCRIPTION
  spec.homepage               = "https://github.com/naoigcat/ruby-keycase"
  spec.license                = "MIT"
  spec.required_ruby_version  = Gem::Requirement.new(">= 2.0.0")

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files                  = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir                 = "exe"
  spec.executables            = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths          = ["lib"]

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
end
