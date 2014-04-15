module Fix
  module Protocol
    module Messages

      #
      # A FIX heartbeat message
      #
      class Heartbeat < Message

        has_field :test_req_id, tag: 112, position: 0

      end
    end
  end
end
