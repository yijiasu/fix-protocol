require_relative '../../../spec_helper'

describe 'Fix::Protocol::Messages::Heartbeat' do

  before do
    @msg = "8=FIX.4.4\x019=74\x0135=0\x0149=AAAA\x0156=BBB\x0134=2\x0152=20080420-15:16:13\x01112=L.0001.0002.0003.151613\x0110=034\x01"
  end

  describe '#test_req_id' do
    it 'should return the correct value' do
      h = Fix::Protocol.parse(@msg)
      h.test_req_id.should eql("L.0001.0002.0003.151613")
    end
  end

  describe '#test_req_id=' do
    it 'should set a body field' do
      h = FP::Messages::Heartbeat.new
      h.test_req_id = 'foo'
      h.body.should eql([[112, 'foo']])
      h.test_req_id.should eql('foo')
    end
  end

  describe '#dump' do
    it 'should return the same message that was parsed' do
      Fix::Protocol.parse(@msg).dump.should eql(@msg)
    end 
  end

end
