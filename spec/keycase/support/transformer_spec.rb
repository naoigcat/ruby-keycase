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

  describe "recursive" do
    it "does not transform Hash keys nested under another Hash when recursive is false" do
      input = { outer_key: { inner_key: 1 } }
      expect(input.with_camel_case_keys(recursive: false)).to eq({ outerKey: { inner_key: 1 } })
    end

    it "still transforms Hash keys that are direct elements of an Array when recursive is false" do
      input = { items: [{ nested_key: 1 }] }
      expect(input.with_camel_case_keys(recursive: false)).to eq({ items: [{ nestedKey: 1 }] })
    end

    it "rejects non-boolean recursive values" do
      expect { {}.with_camel_case_keys(recursive: :no) }.to raise_error(ArgumentError, /recursive/)
    end
  end

  describe "arrays" do
    it "does not traverse Array elements when arrays is false" do
      input = { items: [{ nested_key: 1 }] }
      expect(input.with_camel_case_keys(arrays: false)).to eq({ items: [{ nested_key: 1 }] })
    end

    it "rejects non-boolean arrays values" do
      expect { {}.with_camel_case_keys(arrays: "false") }.to raise_error(ArgumentError, /arrays/)
    end
  end

  describe "only" do
    it "converts only String keys when only includes :string" do
      input = { "foo_bar" => 1, baz_qux: 2 }
      expect(input.with_camel_case_keys(only: [:string])).to eq({ "fooBar" => 1, baz_qux: 2 })
    end

    it "converts only Symbol keys when only includes :symbol" do
      input = { "foo_bar" => 1, baz_qux: 2 }
      expect(input.with_camel_case_keys(only: [:symbol])).to eq({ "foo_bar" => 1, bazQux: 2 })
    end

    it "accepts String and Symbol classes in only" do
      input = { "a_b" => 1, c_d: 2 }
      expect(input.with_camel_case_keys(only: [String, Symbol])).to eq({ "aB" => 1, cD: 2 })
    end

    it "converts no keys when only is empty" do
      input = { foo_bar: 1, "biz_baz" => 2 }
      expect(input.with_camel_case_keys(only: [])).to eq(input)
    end

    it "rejects unsupported only entries" do
      expect { { a: 1 }.with_camel_case_keys(only: [:integer]) }.to raise_error(ArgumentError, /only/)
    end

    it "rejects non-Array only" do
      expect { { a: 1 }.with_camel_case_keys(only: :string) }.to raise_error(ArgumentError, /only/)
    end
  end
end
