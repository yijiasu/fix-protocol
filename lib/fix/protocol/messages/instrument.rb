module Fix
  module Protocol
    module Messages

      #
      # An Instrument component, see http://www.onixs.biz/fix-dictionary/4.4/compBlock_Instrument.html
      #
      class Instrument < MessagePart

        field :symbol, tag: 55, required: true

      end

    end
  end
end

