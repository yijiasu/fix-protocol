require 'polyglot'
require 'treetop'

require 'fix/protocol/message_part'
require 'fix/protocol/repeating_message_part'
require 'fix/protocol/message_header'

module Fix
  module Protocol

    #
    # Represents an instance of a FIX message
    #
    class Message < MessagePart

      part :header, klass: MessageHeader

      def initialize
        super
        header.msg_type = MessageClassMapping.reverse_get(self.class)
      end

      #
      # Dumps this message as a FIX protocol message, it will automatically
      # calculate the body length and and checksum
      #
      # @return [String] The FIX message
      #
      def dump
        if valid?
          dumped = super
          header.body_length = dumped.gsub(/^8=[^\x01]+\x019=[^\x01]+\x01/, '').length
          dumped = super
          "#{dumped}10=#{'%03d' % (dumped.bytes.inject(&:+) % 256)}\x01"
        end
      end

      #
      # Whether this instance is ready to be dumped as a valid FIX message
      #
      # @return [Boolean] Whether there are errors present for this instance
      #
      def valid?
        (errors.nil? || errors.empty?) && parse_failure.nil?
      end

    end
  end
end
