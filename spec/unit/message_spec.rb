require_relative '../spec_helper'

describe Fix::Message do

  before do
    @heartbeat  = "8=FIX.4.1\u00019=112\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=157\u0001"
    @parsed     = Fix::Message.parse(@heartbeat)

    @msg = "8=FIX.4.2\x019=42\x0135=0\x0149=A\x0156=B\x0134=12\x0152=20100304-07:59:30\x0110=185\x01"
  end

  describe '.new' do
    before do
      @ast = double(Object).as_null_object
      Fix::Message.any_instance.stub(:parse_header)
      Fix::Message.stub(:verify_checksum)
      Fix::Message.stub(:verify_body_length)
    end

    it 'should parse the header of a message' do
      Fix::Message.any_instance.should_receive(:parse_header).once
      Fix::Message.new(@ast, @trailer)
    end

    it 'should verify the message body length' do
      Fix::Message.should_receive(:verify_body_length).once
      Fix::Message.new(@ast, @trailer)
    end

    it 'should verify the checksum' do
      Fix::Message.should_receive(:verify_checksum).once
      Fix::Message.new(@ast, @trailer)
    end
  end

  describe '.parse' do
    it 'should return a Fix::ParseFailure when failing to parse a message' do
      Fix::Message.parse('bogus message').should be_a_kind_of(Fix::ParseFailure)
    end

    it 'should parse a heartbeat message' do
      @parsed.should be_a_kind_of(Fix::Messages::Heartbeat)
    end
  end

  describe '.verify_checksum' do
    it 'should approve of a valid checksum' do
      Fix::Message.verify_checksum(@msg).should be_true
    end

    it 'should disapprove of an invalid checksum' do
      Fix::Message.verify_checksum("foo" + @msg).should be_false
    end
  end

  describe '.verify_body_length' do
    it 'should approve of a valid body length' do
      Fix::Message.verify_body_length(@msg).should be_true
    end

    it 'should disapprove of an invalid body length' do
      Fix::Message.verify_body_length("foo" + @msg).should be_false
    end
  end

  describe '#header_tag' do
    it 'should return a value if the tag is present' do
      @parsed.header_tag(49).should eq('BRKR')
    end

    it 'should return nil if no tag is found' do
      @parsed.header_tag(666).should be_nil
    end

    it 'should return nil if the tag exists but is not found at the correct position' do
      @parsed.header_tag(49, 10).should be_nil
    end

    it 'should return the value if the tag is found at the correct position' do
      @parsed.header_tag(49, 3).should eq('BRKR')
    end
  end

  describe '#parse_header_and_trailer' do
    #@parsed.version.should  be('FIX.4.1')
    #@parsed.checksum.should be(157)
  end

end
