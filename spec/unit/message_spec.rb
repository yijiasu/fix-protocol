require_relative '../spec_helper'

describe Fix::Message do

  before do
    @heartbeat  = "8=FIX.4.1\u00019=112\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=157\u0001"
    @parsed     = Fix::Message.parse(@heartbeat)
  end

  describe '.parse' do
    it 'should return a Fix::ParseFailure when failing to parse a message' do
      Fix::Message.parse('bogus message').should be_a_kind_of(Fix::ParseFailure)
    end

    it 'should parse a heartbeat message' do
      @parsed.should be_a_kind_of(Fix::Messages::Heartbeat)
    end
  end

  describe '#value_for_tag' do
    it 'should return a value if the tag is present' do
      @parsed.value_for_tag(49).should eq('BRKR')
    end

    it 'should return nil if no tag is found' do
      @parsed.value_for_tag(666).should be_nil
    end

    it 'should return nil if the tag exists but is not found at the correct position' do
      @parsed.value_for_tag(49, 10).should be_nil
    end

    it 'should return the value if the tag is found at the correct position' do
      @parsed.value_for_tag(49, 3).should eq('BRKR')
    end
  end

  describe '#parse_header_and_trailer' do
    #@parsed.version.should  be('FIX.4.1')
    #@parsed.checksum.should be(157)
  end

end
