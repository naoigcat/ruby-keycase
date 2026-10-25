# frozen_string_literal: true

RSpec.describe "Structure conversion" do # rubocop:disable RSpec/DescribeClass
  %i[camel_case snake_case kebab_case].each do |style|
    describe style do
      let(:method) do
        :"with_#{style}_keys"
      end

      let(:converted_key) do
        Keycase.public_send(style, :foo_bar)
      end

      let(:nested_key) do
        Keycase.public_send(style, :inner_key)
      end

      let(:colliding_struct_class) do
        camelized_member = "fooBar"
        Struct.new(:foo_bar, camelized_member.to_sym)
      end

      [nil, false].each do |first_value|
        it "keeps a colliding #{first_value.inspect} value without traversing the discarded value" do
          cycle = []
          cycle << cycle
          input = { foo_bar: first_value, fooBar: cycle }.freeze

          result = Keycase.public_send(method, input, on_collision: :keep_first)

          expect(result).to eq(converted_key => first_value)
          expect(input[:fooBar]).to equal(cycle)
        end
      end

      it "transforms the winning value when overwriting a Hash collision" do
        input = { foo_bar: nil, fooBar: [{ inner_key: 2 }] }

        result = Keycase.public_send(method, input, on_collision: :overwrite)

        expect(result).to eq(converted_key => [{ nested_key => 2 }])
        expect(input[:fooBar]).to eq([{ inner_key: 2 }])
      end

      it "raises for a collision before traversing the colliding value" do
        cycle = []
        cycle << cycle
        input = { foo_bar: 1, fooBar: cycle }

        expect { Keycase.public_send(method, input) }.to raise_error(
          Keycase::KeyCollisionError, /:fooBar converted to #{Regexp.escape(converted_key.inspect)}/
        )
      end

      it "applies keep_first to Struct collisions without traversing discarded members" do
        input = colliding_struct_class.new(false)
        input[:fooBar] = input
        input.freeze

        result = Keycase.public_send(method, input, on_collision: :keep_first)

        expect(result.members).to eq([converted_key])
        expect(result[converted_key]).to be(false)
        expect(input[:fooBar]).to equal(input)
      end

      it "transforms the winning member when overwriting a Struct collision" do
        input = colliding_struct_class.new(1, { inner_key: 2 }).freeze

        result = Keycase.public_send(method, input, on_collision: :overwrite)

        expect(result.members).to eq([converted_key])
        expect(result[converted_key]).to eq(nested_key => 2)
        expect(input[:fooBar]).to eq(inner_key: 2)
      end

      it "counts depth across Hash, Array, and Struct boundaries" do
        input = { items: [Struct.new(:foo_bar).new({ inner_key: 2 })] }

        expect { Keycase.public_send(method, input, max_depth: 2) }.to raise_error(Keycase::StructureTooDeepError)
        result = Keycase.public_send(method, input, max_depth: 3)
        expect(result[:items].first[converted_key]).to eq(nested_key => 2)
      end

      it "traverses a Hash under a Struct while leaving a Hash under a Hash untouched" do
        inner = { inner_key: 2 }.freeze
        input = { items: [Struct.new(:foo_bar).new({ wrapper: inner })] }

        result = Keycase.public_send(method, input, recursive: false)

        expect(result[:items].first[converted_key][:wrapper]).to equal(inner)
        expect(result[:items].first[converted_key]).not_to equal(input[:items].first[:foo_bar])
      end

      it "leaves frozen caller options unchanged" do
        options = { only: [:symbol].freeze, recursive: true, arrays: true }.freeze

        result = Keycase.public_send(method, { foo_bar: 1, "foo_bar" => 2 }, options)

        expect(result).to eq(converted_key => 1, "foo_bar" => 2)
        expect(options).to eq(only: [:symbol], recursive: true, arrays: true)
      end
    end
  end
end
