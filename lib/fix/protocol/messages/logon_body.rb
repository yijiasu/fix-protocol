module Fix
  module Protocol
    module Messages

      #
      # Body of a logon message
      #
      class LogonBody < UnorderedPart

        field :encrypt_method,      tag: 98,  required: true, type: :integer, default: 0
        field :heart_bt_int,        tag: 108, required: true, type: :integer, default: 30
        field :username,            tag: 553, required: true
        field :reset_seq_num_flag,  tag: 141

      end
    end
  end
end
