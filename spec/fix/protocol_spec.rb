require_relative '../spec_helper'

describe Fix::Protocol do

  describe '.alias_namespace!' do
    it 'should already have been called' do
      expect(FP).to be(Fix::Protocol)
    end
  end

end

