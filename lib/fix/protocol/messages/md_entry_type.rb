module Fix
  module Protocol
    module Messages

      #
      # A market data entry type component, see http://www.onixs.biz/fix-dictionary/4.4/tagNum_269.html
      #
      class MdEntryType < MessagePart

        #
        # The MD entry type mapping
        #
        MD_ENTRY_TYPES = {
          bid:          0,
          ask:          1,
          offer:        1,
          trade:        2,
          index:        3,
          open:         4,
          close:        5,
          settlement:   6,
          high:         7,
          low:          8,
          vwap:         9,
          volume:       'B'
        }

        field :md_entry_type, tag: 269, required: true, mapping: MD_ENTRY_TYPES

      end

    end
  end
end
