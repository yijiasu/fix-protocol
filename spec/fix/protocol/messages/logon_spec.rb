require_relative '../../../spec_helper'

describe 'FP::Messages::Logon' do

  context 'a parsed message' do
    before do
      msg = "8=FIX.4.1\x019=74\x0135=A\x0149=INVMGR\x0156=BRKR\x0134=1\x0152=20000426-12:05:06\x0198=0\x01108=30\x01553=USERNAME\x0110=107\x01"
      @parsed = FP.parse(msg)
    end

    it 'should be of the correct type' do
      @parsed.should be_a_kind_of(FP::Messages::Logon)
    end

    it 'should return the correct field values' do
      @parsed.username.should eql('USERNAME')
      @parsed.heart_bt_int.should eql(30)
    end
  end

  describe '#username' do
    it 'should set a body field' do
      m = FP::Messages::Logon.new
      m.username = 'john'
      m.body.should eql([[553, 'john']])
      m.username.should eql('john')
    end
  end

  describe '#validate' do
    before do 
      @msg = FP::Messages::Logon.new
      @msg.validate
    end

    it 'should be invalid' do
      @msg.valid?.should be_false
    end

    it 'should report the lack of username' do
      @msg.errors.should include('Missing value for <username> field')
    end

    it 'should report the lack of sender_comp_id' do
      @msg.errors.should include('Missing value for <sender_comp_id> field')
    end

    it 'should report the lack of target_comp_id' do
      @msg.errors.should include('Missing value for <target_comp_id> field')
    end
  end 

  describe '#dump' do
    it 'should return nil when the message to dump is invalid' do
      FP::Messages::Logon.new.dump.should be_nil
    end

    it 'should generate a proper message string' do
      msg = FP::Messages::Logon.new
      msg.sender_comp_id  = 'TEST_SENDER'
      msg.target_comp_id  = 'TEST_TARGET'
      msg.username        = 'TEST_USERNAME'
      msg.msg_seq_num     = 1
      msg.dump.should be_a_kind_of(String)
    end
  end

end
