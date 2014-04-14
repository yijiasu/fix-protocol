module Fix
  module Protocol
    module Messages

      #
      # A FIX heartbeat message
      #
      class Heartbeat < Message

        #
        # Returns the test_req_id property of the heartbeat message
        #
        def test_req_id
          body_tag(112, 0)
        end

      end
    end
  end
end
