# frozen_string_literal: true

require "yaml"

RSpec.describe "Release workflow" do # rubocop:disable RSpec/DescribeClass
  it "uses the environment registered for RubyGems trusted publishing" do
    path = File.expand_path("../.github/workflows/release.yml", __dir__)
    workflow = YAML.safe_load(File.read(path))

    expect(workflow.fetch("jobs").fetch("release").fetch("environment")).to eq("release")
    expect(workflow.fetch("permissions").fetch("id-token")).to eq("write")
  end
end
