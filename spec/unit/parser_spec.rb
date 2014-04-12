require_relative '../spec_helper'

describe Fix::Parser do

  before do
    @heartbeat  = "8=FIX.4.1\u00019=112\u000135=0\u000149=BRKR\u000156=INVMGR\u000134=235\u000152=19980604-07:58:28\u0001112=19980604-07:58:28\u000110=157\u0001"
    @parsed_msg = Fix::Parser.parse(@heartbeat)
  end

  it 'should instantiate a Fix::FixParser instance on load' do
    Fix::Parser.class_variable_get(:@@parser).should be_an_instance_of(Fix::FixParser)
  end

  describe '.parse' do
    it 'should return nil when failing to parse a message' do
      Fix::Parser.parse('incorrect message').should be_nil
    end

    it 'should have the correct number of fields' do
      @parsed_msg.body.count.should be(1)
    end
  end

end


