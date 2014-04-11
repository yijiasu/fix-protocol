require_relative '../spec_helper'

require 'fix-protocol'

describe Fix do
  describe '.parse' do
    it 'should delegate the parsing to Fix::Message' do
      Fix::Message.should_receive(:parse).once.with('foo').and_return('bar')
      Fix.parse('foo').should eql('bar')
    end
  end
end

