module Fix
  module Protocol
    module Messages

      #
      # A FIX market data request message
      #
      class MarketDataRequest < Message

        MD_ENTRY_TYPES = {
          bid:        0,
          ask:        1,
          offer:      1,
          trade:      2,
          index:      3,
          open:       4,
          close:      5,
          settlement: 6,
          high:       7,
          low:        8,
          vwap:       9,
          volume:     'B'
        }

        SUBSCRIPTION_TYPES = {
          snapshot:     1,
          updates:      2,
          unsubscribe:  3
        }

        MKT_DPTH_TYPES = {
          full: 0,
          top:  1
        }

        UPDATE_TYPES = {
          full:         0,
          incremental:  1
        }

        has_field :md_req_id,                 tag: 262, required: true
        has_field :subscription_request_type, tag: 263, required: true, type: :integer, mapping: SUBSCRIPTION_TYPES
        has_field :market_depth,              tag: 264, required: true, type: :integer, mapping: MKT_DPTH_TYPES
        has_field :md_update_type,            tag: 265, required: true, type: :integer, mapping: UPDATE_TYPES

        has_repeating_group :md_entry_types,  counter:  267, head: 269, mapping: MD_ENTRY_TYPES
        has_repeating_group :instruments,     counter:  146, head: 55

      end
    end
  end
end


