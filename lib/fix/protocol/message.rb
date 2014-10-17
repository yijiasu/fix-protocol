require 'polyglot'
require 'treetop'

require 'fix/protocol/field_collection'
require 'fix/protocol/grammar'
require 'fix/protocol/field'
require 'fix/protocol/message_part'
require 'fix/protocol/message_header'
require 'fix/protocol/message_class_mapping'
require 'fix/protocol/parse_failure'
require 'fix/protocol/type_conversions'

module Fix
  module Protocol

    #
    # Represents an instance of a FIX message
    #
    class Message < MessagePart


      def initialize

        nodes << MessageHeader.new

      end


    end
  end
end
