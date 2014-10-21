FIX Protocol [![Build Status](https://secure.travis-ci.org/Paymium/fix-protocol.png?branch=master)](http://travis-ci.org/Paymium/fix-protocol) [![Gem Version](https://badge.fury.io/rb/fix-protocol.svg)](http://badge.fury.io/rb/fix-protocol)
=

This library aims to provide a set of useful tools to generate, parse and process messages FIX standard.

Currently it only supports the FIX messages needed for our own use. Additional messages support should however be quite easy to add.

## Example usage

````ruby
require 'fix/protocol'

msg = FP::Messages::Logon.new
msg.sender_comp_id = 'MY_ID'
msg.target_comp_id = 'MY_COUNTERPARTY'
msg.msg_seq_num    = 0
msg.username = 'MY_USERNAME'

if msg.valid?
  msg.dump
else
  puts msg.errors.join(", ")
end
````

Which would output the sample message : `8=FIX.4.4\x019=105\x0135=A\x0149=MY_ID\x0156=MY_COUNTERPARTY\x0134=0\x0152=20141021-10:33:15\x0198=0\x01108=30\x01553=MY_USERNAME\x01141=\x0110=176\x01`

