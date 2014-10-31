require 'fix/protocol/messages/logon_body'

module Fix
  module Protocol
    module Messages

      #
      # A FIX logon message
      #
      class Logon < Message

        extend Forwardable
        def_delegators :body, :encrypt_method, :encrypt_method=, :heart_bt_int, :heart_bt_int=,
          :username, :username=, :reset_seq_num, :reset_seq_num=

        unordered :body, klass: LogonBody

        #
        # Returns the logon-specific errors
        #
        # @return [Array] The error messages
        #
        def errors
          e = []
          e << "Encryption is not supported, the transport level should handle it" unless (encrypt_method == 0)
          e << "Heartbeat interval should be between 10 and 60 seconds"            unless heart_bt_int && heart_bt_int <= 60 && heart_bt_int >= 10
          [super, e].flatten
        end

      end
    end
  end
end

