module Fix

  #
  # Maps the FIX message type codes to message classes
  #
  module MessageClassMapping
    
    # The actual code <-> class mapping
    MAPPING = {
      0 => :heartbeat
    }

    # Require all the message class files
    MAPPING.values.each do |klass|
      require "fix-protocol/messages/#{klass}"
    end

    #
    # Returns the message class associated to a message code
    # 
    # @param msg_type [Integer] The FIX message type code
    # @return [Class] The FIX message class
    #
    def self.get(msg_type)
      Messages.const_get(MAPPING[msg_type.to_i].to_s.split(' ').map(&:capitalize).join.to_sym)
    end

  end
end
