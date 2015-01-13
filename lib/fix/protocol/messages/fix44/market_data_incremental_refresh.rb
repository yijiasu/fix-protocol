require 'fix/protocol/messages/fix44/instrument'
require 'fix/protocol/messages/fix44/md_entry'

module Fix
  module Protocol
    module Messages
      module Fix44

        #
        # A full market refresh
        #
        class MarketDataIncrementalRefresh < Message

          unordered :body do
            field :md_req_id, tag: 262, required: true
            collection :md_entries, counter_tag: 268, klass: FP::Messages::MdEntry
          end

        end
      end
    end
  end
end

