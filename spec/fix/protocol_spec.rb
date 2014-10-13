require_relative '../spec_helper'

describe Fix::Protocol do

  describe '.parse' do
    it 'should delegate the parsing to Fix::Protocol::Message' do
      expect(Fix::Protocol::Message).to receive(:parse).once.with('foo').and_return('bar')
      expect(Fix::Protocol.parse('foo')).to eql('bar')
    end
  end

  describe '.alias_namespace!' do
    it 'should already have been called' do
      expect(FP).to be(Fix::Protocol)
    end
  end

end

