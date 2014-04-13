require_relative '../spec_helper'

describe Fix::Message do

  before do
    @heartbeat = "8=FIX.4.1\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
  end

  describe '.parse' do

    it 'should return a failure when failing to parse a message' do
      failure = Fix.parse('bogus message')
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Failed to parse message string")
    end

    it 'should return a failure when the version is not supported' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Unsupported version: FOO.4.2")
    end

    it 'should return a failure when the message type is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=X\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Unknown message type: X")
    end

    it 'should return a failure when the checksum is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Incorrect checksum")
    end

    it 'should return a failure when the body length is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112= <additionnal length> 19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Incorrect body length")
    end

    it 'should return a failure when the sending_time is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:XX:28\u0001112= <additionnal length> 19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Incorrect sending time: 19980604-07:XX:28")
    end

    it 'should return a failure when the msg_seq_num is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=0\u000152=19980604-07:58:28\u0001112= <additionnal length> 19980604-07:58:28\u000110=235\u0001"
      failure = Fix.parse(msg)
      failure.should be_a_kind_of(Fix::ParseFailure)
      failure.errors.should include("Incorrect sequence number: 0")
    end

    it 'should parse a message to its correct class' do
      Fix.parse(@heartbeat).should be_a_kind_of(Fix::Messages::Heartbeat)
    end
  end

  describe '.verify_checksum' do
    it 'should approve of a valid checksum' do
      Fix::Message.verify_checksum(@heartbeat).should be_true
    end

    it 'should disapprove of an invalid checksum' do
      Fix::Message.verify_checksum("foo" + @heartbeat).should be_false
    end
  end

  describe '.verify_body_length' do
    it 'should approve of a valid body length' do
      Fix::Message.verify_body_length(@heartbeat).should be_true
    end

    it 'should disapprove of an invalid body length' do
      Fix::Message.verify_body_length("foo" + @heartbeat).should be_false
    end
  end

  context 'when a message has been parsed' do
    before do
      @parsed = Fix::Message.parse(@heartbeat)
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

    describe '#body' do
      it 'should have the correct number of fields' do
        @parsed.body.count.should be(1)
      end
    end

    describe '#valid?' do
      it 'should not revalidate if not necessary' do
        @parsed.should_receive(:validate).never
        @parsed.valid?
      end

      it 'should revalidate if required' do
        @parsed.should_receive(:validate).once.with(true)
        @parsed.valid?(true)
      end
    end

  end
end

