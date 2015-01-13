require 'fix/protocol/version'
require 'fix/protocol/messages'
require 'fix/protocol/message_class_mapping'
require 'fix/protocol/parse_failure'

#
# Main Fix namespace
#
module Fix

  #
  # Main protocol namespace
  #
  module Protocol

    #
    # The default version of the protocol to use
    #
    DEFAULT_FIX_PROTOCOL_VERSION = 'FIX.4.4'

    #
    # Parses a string into a Fix::Protocol::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Protocol::Message] A +Fix::Protocol::Message+ instance, or a +Fix::Protocol::ParseFailure+ in case of failure
    #
    def self.parse(str)
      errors    = []
      msg_type  = str.match(/^8\=[^\x01]+\x019\=[^\x01]+\x0135\=([^\x01]+)\x01/)

      unless str.match(/^8\=[^\x01]+\x019\=[^\x01]+\x0135\=[^\x01]+\x01.+10\=[^\x01]+\x01/)
        FP::ParseFailure.new("Malformed message <#{str}>")
      else

        klass = MessageClassMapping.get(msg_type[1])

        unless klass
          errors << "Unknown message type <#{msg_type[1]}>"
        end

        # Check message length
        length = str.gsub(/10\=[^\x01]+\x01$/, '').gsub(/^8\=[^\x01]+\x019\=([^\x01]+)\x01/, '').length
        if length != $1.to_i
          errors << "Incorrect body length"
        end

        # Check checksum
        checksum = str.match(/10\=([^\x01]+)\x01/)[1]
        expected = ('%03d' % (str.gsub(/10\=[^\x01]+\x01/, '').bytes.inject(&:+) % 256))
        if checksum != expected
          errors << "Incorrect checksum, expected <#{expected}>, got <#{checksum}>"
        end

        if errors.empty?
          msg = klass.parse(str)

          if msg.valid?
            msg
          else
            FP::ParseFailure.new(msg.errors)
          end
        else
          FP::ParseFailure.new(errors)
        end
      end
    end

    #
    # Alias the +Fix::Protocol+ namespace to +FP+ if possible
    #
    def self.alias_namespace!
      Object.const_set(:FP, Protocol) unless Object.const_defined?(:FP)
    end

    #
    # Formats a symbol as a proper class name
    #
    # @param s [Symbol] A name to camelcase
    # @return [Symbol] A camelcased class name
    #
    def self.camelcase(s)
      s.to_s.split(' ').map { |str| str.split('_') }.flatten.map(&:capitalize).join.to_sym
    end

    #
    # Sets up the autoloading mechanism according to the relevant FIX version
    #
    def self.setup_autoload!
      ver = @fix_protocol_version || DEFAULT_FIX_PROTOCOL_VERSION
      folder = File.join(File.dirname(__FILE__), "protocol/messages/#{ver.gsub(/\./, '').downcase}")

      Dir["#{folder}/*.rb"].each do |file| 
        klass = camelcase(file.match(/([^\/]+)\.rb$/)[1])
        Messages.autoload(klass, file)
      end

    end
  end
end

Fix::Protocol.alias_namespace!
Fix::Protocol.setup_autoload!

require 'fix/protocol/message'

