# frozen_string_literal: true

RSpec.describe Keycase::Support::Acronyms do
  describe ".index" do
    it "returns an empty hash for nil" do
      expect(described_class.index(nil)).to eq({})
    end

    it "maps downcased spellings to the given surface form" do
      expect(described_class.index(%w[API HTTP ID])).to eq(
        "api" => "API",
        "http" => "HTTP",
        "id" => "ID"
      )
    end

    it "ignores blank entries" do
      expect(described_class.index(["API", "", nil])).to eq("api" => "API")
    end

    it "uses the last entry when downcased forms collide" do
      expect(described_class.index(%w[API Api])).to eq("api" => "Api")
    end
  end

  describe ".segment" do
    let(:map) { described_class.index(%w[API ID]) }

    it "replaces a word with the configured acronym (case-insensitive match)" do
      expect(described_class.segment("api", map)).to eq "API"
      expect(described_class.segment("Api", map)).to eq "API"
      expect(described_class.segment("API", map)).to eq "API"
    end

    it "otherwise behaves like String#capitalize" do
      expect(described_class.segment("response", map)).to eq "Response"
      expect(described_class.segment("CASE", map)).to eq "Case"
    end
  end

  describe ".leading_acronym?" do
    let(:map) { described_class.index(["API"]) }

    it "returns true when the first token matches a configured acronym" do
      expect(described_class.leading_acronym?("API", map)).to be true
      expect(described_class.leading_acronym?("api", map)).to be true
    end

    it "returns false when the first token does not match" do
      expect(described_class.leading_acronym?("my", map)).to be false
    end

    it "returns false when the first word is nil" do
      expect(described_class.leading_acronym?(nil, map)).to be false
    end
  end
end
