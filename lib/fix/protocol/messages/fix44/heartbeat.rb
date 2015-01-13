module Fix
  module Protocol
    module Messages
      module Fix44

        #
        # A FIX heartbeat message
        #
        class Heartbeat < ::Fix::Protocol::Message

          field :test_req_id, tag: 112

        end
      end
    end
  end
end
