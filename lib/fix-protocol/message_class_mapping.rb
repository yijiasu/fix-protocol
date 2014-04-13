require 'fix-protocol/messages'

module Fix

  #
  # Maps the FIX message type codes to message classes
  #
  module MessageClassMapping
    
    # The actual code <-> class mapping
    MAPPING = {
      '0' => :heartbeat
    }

    #
    # Returns the message class associated to a message code
    # 
    # @param msg_type [Integer] The FIX message type code
    # @return [Class] The FIX message class
    #
    def self.get(msg_type)
      Messages.const_get(camelcase(MAPPING[msg_type])) if MAPPING.has_key?(msg_type)
    end

    #
    # Returns the message code associated to a message class
    #
    # @param msg_type [Integer] The FIX message type code
    # @return [Class] The FIX message class
    #
    def self.reverse_get(klass)
      key = klass.name.split('::').last.gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase.to_sym
      MAPPING.find { |p| p[1] == key }[0]
    end

    #
    # Formats a symbol as a proper class name
    #
    # @param s [Symbol] A name to camelcase
    # @return [Symbol] A camelcased class name
    #
    def self.camelcase(s)
      s.to_s.split(' ').map(&:capitalize).join.to_sym
    end
    
    #
    # Mark all the message classes for autoloading
    #
    MAPPING.values.each do |klass|
      Messages.autoload(camelcase(klass), "fix-protocol/messages/#{klass}")
    end

  end
end
