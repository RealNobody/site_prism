require 'spec_helper'

RSpec.describe '#combine_args' do
  class FakeContainerClass
    include SitePrism::ElementContainer
  end

  let(:subject) { FakeContainerClass.new }
  let(:array_args1) { [:css, '#argument-1'] }
  let(:array_args2) { [:css, '#argument-2'] }
  let(:options_args1) { [{ minimum: 8 }] }
  let(:options_args2) { [{ count: 12 }] }
  let(:array_options_args1) { [:css, '#argument-with-options-1', { visible: false }] }
  let(:array_options_args2) { [:css, '#argument-with-options-2', { timeout: 30 }] }

  it 'combines 2 arrays' do
    expect(subject.send(:combine_args, array_args1, array_args2)).to eq [:css, '#argument-1', :css, '#argument-2', {}]
  end

  it 'combines 2 arrays even if one is empty' do
    expect(subject.send(:combine_args, array_args1, [])).to eq [:css, '#argument-1', {}]
  end

  it 'combines an array and options' do
    expect(subject.send(:combine_args, array_args1, options_args2)).to eq [:css, '#argument-1', { count: 12 }]
  end

  it 'combines an array and an array with options' do
    expect(subject.send(:combine_args, array_args1, array_options_args2)).to eq [:css, '#argument-1', :css, '#argument-with-options-2', { timeout: 30 }]
  end

  it 'combines an array with options and an array' do
    expect(subject.send(:combine_args, array_options_args1, array_args2)).to eq [:css, '#argument-with-options-1', :css, '#argument-2', { visible: false }]
  end

  it 'combines an array with options and options' do
    expect(subject.send(:combine_args, array_options_args1, options_args2)).to eq [:css, '#argument-with-options-1', { visible: false, count: 12 }]
  end

  it 'combines an array with options and an array with options' do
    expect(subject.send(:combine_args, array_options_args1, array_options_args2)).to eq [:css, '#argument-with-options-1', :css, '#argument-with-options-2', { visible: false, timeout: 30 }]
  end

  it 'combines options and an array' do
    expect(subject.send(:combine_args, options_args1, array_args2)).to eq [:css, '#argument-2', { minimum: 8 }]
  end

  it 'combines options and an array with options' do
    expect(subject.send(:combine_args, options_args1, array_options_args2)).to eq [:css, '#argument-with-options-2', { minimum: 8, timeout: 30 }]
  end

  it 'combines options and options' do
    expect(subject.send(:combine_args, options_args1, options_args2)).to eq [{ minimum: 8, count: 12 }]
  end

  it 'merges options so that it prefers the passed in options' do
    array_options_args1[-1][:test_value] = 1
    array_options_args2[-1][:test_value] = 2

    expect(subject.send(:combine_args, array_options_args1, array_options_args2)).to eq [:css, '#argument-with-options-1', :css, '#argument-with-options-2', { visible: false, timeout: 30, test_value: 2 }]
  end
end
