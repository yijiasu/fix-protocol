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

    attr_accessor :raw, :header, :body, :checksum, :version, :body_length, :sender_comp_id, :target_comp_id, :msg_seq_num, :sending_time, :checksum

    #
    # Parses a string into a Fix::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def self.parse(str)
      ast = Parser.parse(str)

      if ast
        msg_klass = MessageClassMapping.get(ast.msg_type)
        msg_klass.new(ast, str)
      else
        ParseFailure.new
      end
    end

    def initialize(ast, str)
      @header   = ast.header
      @body     = ast.body
      @checksum = ast.checksum
      @raw      = str

      parse_header
      Message.verify_body_length(str)
      Message.verify_checksum(str)
    end

    #
    # Verifies that the checksum of this message is correct
    #
    # @param str [String] The raw FIX message
    # @return [Boolean] Whether the checksum is correct
    #
    def self.verify_checksum(str)
      chk = str.match(/10=([^\x01]+)\x01\Z/)[1]

      if chk && chk.length == 3
        sub = str.gsub(/10=[^\x01]+\x01\Z/, '')
        chk.to_i == (sub.bytes.inject(&:+) % 256)
      end
    end

    #
    # Verifies that the reported body length is correct
    # 
    # @param str [String] The raw FIX message
    # @return [Boolean] Whether the body length is 
    #
    def self.verify_body_length(str)
      if m = str.match(/\A8=[^\x01]+\x019=([^\x01]+)\x01(.*)10=[0-9]{3}\x01\Z/)
        expected  = m[1].to_i
        actual    = m[2].length
        expected  == actual
      end
    end

    #
    # Reads the FIX header, validates the length of the message and its checksum
    #
    def parse_header
      @version        = header_tag(8, 0)
      @body_length    = header_tag(9, 1).to_i
      @sender_comp_id = header_tag(49)
      @sender_comp_id = header_tag(56)
      @msg_seq_num    = header_tag(34)
      @sending_time   = header_tag(52)
    end

    #
    # Returns the first value of a field in the given fields array, 
    # if the +position+ is specified then it will be enforced.
    #
    # +nil+ is returned if the field isn't found, or isn't found at the specified position
    #
    # @param fields [Array] The fields among which the tag value should be searched
    # @param tag [Fixnum] The tag code for which the value should be fetched
    # @param position [Fixnum] The position at which the field is supposed to be located 
    #
    def get_tag_value(fields, tag, position = nil)
      if position
        fields[position] && 
          (fields[position][0] == tag) && 
          fields[position][1]
      else
        fld = fields.find { |f| f[0] == tag }
        fld && fld[1]
      end
    end

    #
    # Returns the first value of a field in a message header, 
    # if the +position+ is specified then it will be enforced.
    #
    # +nil+ is returned if the field isn't found, or isn't found at the specified position
    #
    # @param tag [Fixnum] The tag code for which the value should be fetched
    # @param position [Fixnum] The position at which the field is supposed to be located 
    #
    def header_tag(tag, position = nil)
      get_tag_value(header, tag, position)
    end

    #
    # Returns the first value of a field in a message body, 
    # if the +position+ is specified then it will be enforced.
    #
    # +nil+ is returned if the field isn't found, or isn't found at the specified position
    #
    # @param tag [Fixnum] The tag code for which the value should be fetched
    # @param position [Fixnum] The position at which the field is supposed to be located 
    #
    def body_tag(tag, position = nil)
      get_tag_value(body, tag, position)
    end

  end
end
