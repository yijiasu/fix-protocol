require_relative '../spec_helper'

describe Fix::Message do

  describe '.parse' do
    it 'should return a Fix::ParseFailure when failing to parse a message' do
      Fix::Message.parse('bogus message').should be_a_kind_of(Fix::ParseFailure)
    end
  end

end
