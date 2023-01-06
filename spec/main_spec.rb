# frozen_string_literal: true

require 'rspec'
require './main'

describe 'Main' do
  context 'when calling hello_world' do
    it 'returns Hello World' do
      expect(hello_world).to eq 'Hello world!'
    end
  end
end
