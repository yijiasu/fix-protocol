require 'fix/protocol/messages/md_entry_type'
require 'fix/protocol/messages/instrument'

module Fix
  module Protocol
    module Messages

      #
      # A FIX market data request message
      #
      class MarketDataRequest < Message

        #
        # The subscription type, see: http://www.onixs.biz/fix-dictionary/4.4/tagNum_263.html
        #
        SUBSCRIPTION_TYPES = {
          snapshot:     1,
          updates:      2,
          unsubscribe:  3
        }

        #
        # Whether to return the full book or only the best bid/ask
        #
        MKT_DPTH_TYPES = {
          full: 0,
          top:  1
        }

        #
        # Whether to send a full market depth on each update, we'll probably only support the incremental type
        #
        UPDATE_TYPES = {
          full:         0,
          incremental:  1
        }

        field :md_req_id,                 tag: 262, required: true
        field :subscription_request_type, tag: 263, required: true, type: :integer, mapping: SUBSCRIPTION_TYPES
        field :market_depth,              tag: 264, required: true, type: :integer, mapping: MKT_DPTH_TYPES
        field :md_update_type,            tag: 265, required: true, type: :integer, mapping: UPDATE_TYPES

        collection :md_entry_types, counter_tag: 267, klass: FP::Messages::MdEntryType
        collection :instruments,    counter_tag: 146, klass: FP::Messages::Instrument  

      end
    end
  end
end


