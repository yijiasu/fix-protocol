require_relative '../spec_helper'

describe Fix::Protocol do

  describe '.parse' do
    it 'should delegate the parsing to Fix::Protocol::Message' do
      Fix::Protocol::Message.should_receive(:parse).once.with('foo').and_return('bar')
      Fix::Protocol.parse('foo').should eql('bar')
    end
  end

  describe '.alias_namespace!' do
    it 'should already have been called' do
      FP.should be(Fix::Protocol)
    end
  end

end

