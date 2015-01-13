module Fix
  module Protocol
    module Messages
      module Fix44

        #
        # A FIX test request message
        #
        class TestRequest < Message

          field :test_req_id, tag: 112, required: true

        end
      end
    end
  end
end
