require 'fix/protocol/messages/fix44/instrument'
require 'fix/protocol/messages/fix44/md_entry'

module Fix
  module Protocol
    module Messages

      #
      # A full market refresh
      #
      class MarketDataSnapshot < Message

        unordered :body do
          field :md_req_id, tag: 262, required: true
          part  :instrument, klass: FP::Messages::Instrument
          collection :md_entries, counter_tag: 268, klass: FP::Messages::MdEntry
        end

      end
    end
  end
end

