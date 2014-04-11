require_relative '../spec_helper'

describe Fix::Message do

  before do
    @heartbeat  = "8=FIX.4.1\u00019=112\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=157\u0001"
  end

  describe '.parse' do
    it 'should return a Fix::ParseFailure when failing to parse a message' do
      Fix::Message.parse('bogus message').should be_a_kind_of(Fix::ParseFailure)
    end

    it 'should parse a heartbeat message' do
      Fix::Message.parse(@heartbeat).should be_a_kind_of(Fix::Messages::Heartbeat)
    end
  end

end
