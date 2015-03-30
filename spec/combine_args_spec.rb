require "spec_helper"

RSpec.describe "#combine_args" do
  class FakeContainerClass
    include SitePrism::ElementContainer
  end

  let(:subject) { FakeContainerClass.new }
  let(:array_args1) { rand(0..5).times.map { rand(50..200).times.map { ('a'..'z').to_a.sample }.join("") } }
  let(:array_args2) { rand(0..5).times.map { rand(50..200).times.map { ('a'..'z').to_a.sample }.join("") } }
  let(:options_args1) { [rand(1..5).times.reduce({}) { |hash, _| hash[rand(5..20).times.map { ('a'..'z').to_a.sample }.join("")] = rand(50..200).times.map { ('a'..'z').to_a.sample }.join(""); hash }] }
  let(:options_args2) { [rand(1..5).times.reduce({}) { |hash, _| hash[rand(5..20).times.map { ('a'..'z').to_a.sample }.join("")] = rand(50..200).times.map { ('a'..'z').to_a.sample }.join(""); hash }] }
  let(:array_options_args1) do
    array = rand(1..5).times.map { rand(50..200).times.map { ('a'..'z').to_a.sample }.join("") }
    array << rand(1..5).times.reduce({}) { |hash, _| hash[rand(5..20).times.map { ('a'..'z').to_a.sample }.join("")] = rand(50..200).times.map { ('a'..'z').to_a.sample }.join(""); hash }
    array
  end
  let(:array_options_args2) do
    array = rand(1..5).times.map { rand(50..200).times.map { ('a'..'z').to_a.sample }.join("") }
    array << rand(1..5).times.reduce({}) { |hash, _| hash[rand(5..20).times.map { ('a'..'z').to_a.sample }.join("")] = rand(50..200).times.map { ('a'..'z').to_a.sample }.join(""); hash }
    array
  end

  it "combines 2 arrays" do
    expect(subject.send(:combine_args, array_args1, array_args2)).to eq [*array_args1, *array_args2, {}]
  end

  it "combines an array and options" do
    expected_values = []
    expected_values += array_args1
    expected_values << options_args2[0]

    expect(subject.send(:combine_args, array_args1, options_args2)).to eq expected_values
  end

  it "combines an array and an array with options" do
    expect(subject.send(:combine_args, array_args1, array_options_args2)).to eq [*array_args1, *array_options_args2]
  end

  it "combines an array with options and an array" do
    expected_values = []
    expected_values += array_options_args1[0..-2]
    expected_values += array_args2
    expected_values << array_options_args1[-1]

    expect(subject.send(:combine_args, array_options_args1, array_args2)).to eq expected_values
  end

  it "combines an array with options and options" do
    expected_values = []
    expected_values += array_options_args1[0..-2]
    expected_values << array_options_args1[-1].merge(options_args2[0])

    expect(subject.send(:combine_args, array_options_args1, options_args2)).to eq expected_values
  end

  it "combines an array with options and an array with options" do
    expected_values = []
    expected_values += array_options_args1[0..-2]
    expected_values += array_options_args2[0..-2]
    expected_values << array_options_args1[-1].merge(array_options_args2[-1])

    expect(subject.send(:combine_args, array_options_args1, array_options_args2)).to eq expected_values
  end

  it "combines options and an array" do
    expected_values = []
    expected_values += array_args2
    expected_values << options_args1[0]

    expect(subject.send(:combine_args, options_args1, array_args2)).to eq expected_values
  end

  it "combines options and an array with options" do
    expected_values = []
    expected_values += array_options_args2[0..-2]
    expected_values << options_args1[0].merge(array_options_args2[-1])

    expect(subject.send(:combine_args, options_args1, array_options_args2)).to eq expected_values
  end

  it "combines options and options" do
    expected_values = []
    expected_values << options_args1[0].merge(options_args2[0])

    expect(subject.send(:combine_args, options_args1, options_args2)).to eq expected_values
  end

  it "merges options so that it prefers the passed in options" do
    array_options_args1[-1][:test_value] = 1
    array_options_args2[-1][:test_value] = 2
    expected_values = []
    expected_values += array_options_args1[0..-2]
    expected_values += array_options_args2[0..-2]
    expected_values << array_options_args1[-1].merge(array_options_args2[-1])

    expect(subject.send(:combine_args, array_options_args1, array_options_args2)).to eq expected_values
    expect(expected_values[-1][:test_value]).to eq 2
  end
end
