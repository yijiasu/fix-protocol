module Fix
  module Protocol
    module Messages

      class Instrument < MessagePart

        field :symbol, tag: 55, required: true

      end

    end
  end
end

