module Fix
  module Protocol
    module Messages

      #
      # A FIX test request message
      #
      class TestRequest < Message

        has_field :test_req_id, tag: 112, position: 0, required: true

      end
    end
  end
end
