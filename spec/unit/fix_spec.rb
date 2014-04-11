require_relative '../spec_helper'

describe Fix do
  describe '.parse' do
    it 'should delegate the parsing to Fix::Parser' do
      Fix::Parser.should_receive(:parse).once.with('foo').and_return('bar')
      Fix.parse('foo').should eql('bar')
    end
  end
end

