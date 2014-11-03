module Fix
  module Protocol
    module Messages

      #
      # An Instrument component, see http://www.onixs.biz/fix-dictionary/4.4/compBlock_Instrument.html
      #
      class Instrument < MessagePart

        field :symbol, tag: 55, required: true

        #
        # Checks whether the start of the given string can be parsed as this particular field
        #
        # @param str [String] The string for which we want to parse the beginning
        # @return [Boolean] Whether the beginning of the string can be parsed for this field
        #
        def can_parse?(str)
          str =~ /55\=[^\x01]+\x01/
        end

      end
    end
  end
end
