require 'fix-protocol/message_class_mapping'
require 'fix-protocol/parser'
require 'fix-protocol/parse_failure'

module Fix

  #
  # Represents an instance of a FIX message
  #
  class Message

    #
    # The known FIX versions that will be parsed
    #
    FIX_VERSIONS = %w{ 4.1 4.2 4.4 }.map { |v| "FIX.#{v}" }

    attr_accessor :raw, :fields, :version, :body_length, :sender_comp_id, :target_comp_id, :msg_seq_num, :sending_time, :checksum

    #
    # Parses a string into a Fix::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def self.parse(str)
      ast = Parser.parse(str)

      if ast
        fields = ast.fields
        msg_klass = MessageClassMapping.get(fields[2][1])
        msg_klass.from_fields(fields, str)
      else
        ParseFailure.new
      end
    end

    def initialize(fields, str)
      @raw    = str
      @fields = fields
      parse_header_and_trailer
      #check_structure
    end

    #
    # Reads the FIX header, validates the length of the message and its checksum
    #
    def parse_header_and_trailer
      @version        = value_for_tag(8, 0, FIX_VERSIONS)
      @body_length    = value_for_tag(9, 1).to_i
      @sender_comp_id = value_for_tag(49)
      @sender_comp_id = value_for_tag(56)
      @msg_seq_num    = value_for_tag(34)
      @sending_time   = value_for_tag(52)
      @checksum       = value_for_tag(10, fields.length - 1).to_i
      
      # check message body length
      # check checksum
    end

    #
    # Returns the first value of a field in a message, if the +position+ 
    # is specified then it will be enforced.
    #
    # +nil+ is returned if the field isn't found, or isn't found at the specified position
    #
    # @param tag [Fixnum] The tag code for which the value should be fetched
    # @param position [Fixnum] The position at which the field is supposed to be located 
    #
    def value_for_tag(tag, position = nil, allowed_values = nil)
      if position
        fields[position] && 
          (fields[position][0].to_i == tag) && 
          fields[position][1]
      else
        fld = fields.find { |f| f[0].to_i == tag }
        fld && fld[1]
      end
    end

  end
end
