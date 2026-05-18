# frozen_string_literal: true

RSpec.describe Keycase::Support::Transformer do
  using Keycase::CamelCase

  describe "cycle detection" do
    it "raises when a Hash references itself" do
      h = {}
      h[:key] = h
      expect { h.with_camel_case_keys }.to raise_error(Keycase::CircularStructureError)
    end

    it "raises when an Array references itself" do
      a = []
      a << a
      expect { a.with_camel_case_keys }.to raise_error(Keycase::CircularStructureError)
    end

    it "does not merge duplicate subtrees referenced from multiple paths" do
      inner = { plain_key: 1 }
      h = { first: inner, second: inner }
      result = h.with_camel_case_keys
      expect(result[:first]).to eq({ plainKey: 1 })
      expect(result[:second]).to eq({ plainKey: 1 })
      expect(result[:first]).not_to equal(result[:second])
    end
  end

  describe "max_depth" do
    it "allows shallow nesting within max_depth" do
      expect({ a: { b: 1 } }.with_camel_case_keys(max_depth: 2)).to eq({ a: { b: 1 } })
    end

    it "raises when nesting exceeds max_depth" do
      deep = { a: { b: { c: 1 } } }
      expect { deep.with_camel_case_keys(max_depth: 1) }.to raise_error(Keycase::StructureTooDeepError)
    end
  end

  describe "key collision detection" do
    it "raises when converted Hash keys collide" do
      hash = { foo_bar: 1, fooBar: 2 }
      expect { hash.with_camel_case_keys }.to raise_error(Keycase::KeyCollisionError)
    end

    it "accepts on_collision: :overwrite (last key wins)" do
      hash = { foo_bar: 1, fooBar: 2 }
      expect(hash.with_camel_case_keys(on_collision: :overwrite)).to eq({ fooBar: 2 })
    end

    it "accepts on_collision: :keep_first (first key wins)" do
      hash = { foo_bar: 1, fooBar: 2 }
      expect(hash.with_camel_case_keys(on_collision: :keep_first)).to eq({ fooBar: 1 })
    end

    it "rejects unknown on_collision values" do
      expect { { a: 1 }.with_camel_case_keys(on_collision: :merge) }.to raise_error(ArgumentError, /on_collision/)
    end
  end
end
