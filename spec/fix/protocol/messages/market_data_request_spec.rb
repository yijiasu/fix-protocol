require_relative '../../../spec_helper'

describe 'Fix::Protocol::Messages::MarketDataRequest' do

  before do
    @msgx = "8=FIX.4.4|9=139|35=V|49=DAVID_SND|56=PYMBTCDEV|34=3|52=20141014-11:24:41|262=X|263=1|264=0|265=1|267=6|269=0|269=1|269=2|269=4|269=5|269=9|146=1|55=EURXBT|10=021|".gsub(/\|/, "\x01")
  end

  describe '#instruments' do
    it 'should return the correct instruments value' do
      msg = FP.parse(@msgx)
      expect(msg.instruments.first.symbol).to eql('EURXBT')
    end
  end

  describe '#md_entry_types' do
    it 'should return the correct mapped values' do
      msg = Fix::Protocol.parse(@msg)
      expect(msg.md_entry_types.sort).to eql([:bid, :ask, :trade, :open, :vwap, :close].sort)
    end
  end

  describe '#raw_md_entry_types' do
    it 'should return the correct raw values' do
      msg = Fix::Protocol.parse(@msg)
      expect(msg.md_entry_types.map { |met| met.md_entry_type }).to eql(["0", "1", "2", "4", "5", "9"])
    end
  end

  describe '#md_entry_types=' do
    it 'should accept symbols and map them to their numerical values' do
      msg = FP::Messages::MarketDataRequest.new
      msg.md_entry_types = [:bid, :ask, :close, 6]
      expect(msg.md_entry_types).to eql([:bid, :ask, :close, :settlement])
      expect(msg.raw_md_entry_types).to eql(%w{ 0 1 5 6 })
    end

    it 'should handle an absence of mapping gracefully' do
      msg = FP::Messages::MarketDataRequest.new
      msg.md_entry_types = [:bid, :ask, :close, 42]
      expect(msg.md_entry_types).to eql([:bid, :ask, :close, '42'])
      expect(msg.raw_md_entry_types).to eql(%w{ 0 1 5 42 })
    end
  end

  describe '#dump' do
    it 'should return the same message' do
      expect(FP.parse(@msg).dump).to eql(@msg)
    end
  end

end

