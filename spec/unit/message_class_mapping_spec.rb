require_relative '../spec_helper'

require 'fix-protocol/message_class_mapping'

describe 'Fix::MessageClassMapping' do

  describe '.get' do
    it 'should return the correct mapping for the 0 message type' do
      Fix::MessageClassMapping.get('0').should be(Fix::Messages::Heartbeat)
    end
  end

end
