module Fix
  module Protocol

    #
    # Represents a failure to parse a message, the +errors+ collection
    # should contain the specific error messages
    #
    class ParseFailure

      attr_accessor :errors

      def initialize(errs = nil)
        @errors = [errs].flatten.compact
      end

    end
  end
end
