require_relative '../../spec_helper'

describe Fix::Protocol::Message do

  before do
    @heartbeat = "8=FIX.4.1\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
  end

  describe '.parse' do

    it 'should return a failure when failing to parse a message' do
      failure = Fix::Protocol.parse('bogus message')
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Failed to parse message string")
    end

    it 'should return a failure when the version is not supported' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Unsupported version: FOO.4.2")
    end

    it 'should return a failure when the message type is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=X\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Unknown message type: X")
    end

    it 'should return a failure when the checksum is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Incorrect checksum")
    end

    it 'should return a failure when the body length is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112= <additionnal length> 19980604-07:58:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Incorrect body length")
    end

    it 'should return a failure when the sending_time is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:XX:28\u0001112=19980604-07:XX:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Incorrect sending time")
    end

    it 'should return a failure when the msg_seq_num is incorrect' do
      msg = "8=FOO.4.2\u00019=73\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=0\u000152=19980604-07:58:28\u0001112= <additionnal length> 19980604-07:58:28\u000110=235\u0001"
      failure = Fix::Protocol.parse(msg)
      expect(failure).to be_a_kind_of(Fix::Protocol::ParseFailure)
      expect(failure.errors).to include("Incorrect sequence number")
    end

    it 'should parse a message to its correct class' do
      expect(Fix::Protocol.parse(@heartbeat)).to be_a_kind_of(Fix::Protocol::Messages::Heartbeat)
    end
  end

  describe '.verify_checksum' do
    it 'should approve of a valid checksum' do
      expect(Fix::Protocol::Message.verify_checksum(@heartbeat)).to be_truthy
    end

    it 'should disapprove of an invalid checksum' do
      expect(Fix::Protocol::Message.verify_checksum("foo" + @heartbeat)).to be_falsey
    end
  end

  describe '.verify_body_length' do
    it 'should approve of a valid body length' do
      expect(Fix::Protocol::Message.verify_body_length(@heartbeat)).to be_truthy
    end

    it 'should disapprove of an invalid body length' do
      expect(Fix::Protocol::Message.verify_body_length("foo" + @heartbeat)).to be_falsey
    end
  end

  context 'when a message has been parsed' do
    before do
      @parsed = Fix::Protocol::Message.parse(@heartbeat)
    end

    describe '#sender_comp_id' do
      it 'should return a value if the tag is present' do
        expect(@parsed.sender_comp_id).to eq('BRKR')
      end
    end

    describe '#sending_time' do
      it 'should set the default value if relevant' do
        expect(FP::Messages::Heartbeat.new.sending_time).to be_a_kind_of(Time)
      end
    end

    describe '#version' do
      it 'should return the default value if relevant' do
        expect(FP::Messages::Heartbeat.new.version).to eql('FIX.4.4')
      end
    end

    describe '#get_tag_value' do
      it 'should return nil if no tag is found' do
        expect(@parsed.get_tag_value(:header, 666)).to be_nil
      end

      it 'should return nil if the tag exists but is not found at the correct position' do
        expect(@parsed.get_tag_value(:header, 49, { position: 10 })).to be_nil
      end

      it 'should return the value if the tag is found at the correct position' do
        expect(@parsed.get_tag_value(:header, 49, { position: 3 })).to eq('BRKR')
      end
    end

    describe '#body' do
      it 'should have the correct number of fields' do
        expect(@parsed.body.count).to be(1)
      end
    end

    describe '#valid?' do
      it 'should not revalidate if not necessary' do
        expect(@parsed).to receive(:validate).never
        @parsed.valid?
      end

      it 'should revalidate if required' do
        expect(@parsed).to receive(:validate).once.with(true)
        @parsed.valid?(true)
      end
    end

  end
end

