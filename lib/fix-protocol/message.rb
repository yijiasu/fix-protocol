require 'polyglot'
require 'treetop'

require 'fix-protocol/grammar'
require 'fix-protocol/message_class_mapping'
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

    attr_accessor :raw, :header, :body, :checksum, :errors, :version, :body_length,
      :sender_comp_id, :target_comp_id, :msg_seq_num, :sending_time, :checksum

    def initialize(ast, str)
      @header   = ast.header
      @body     = ast.body
      @raw      = str

      parse_header
      validate
    end

    #
    # Parses a string into a Fix::Message instance
    #
    # @param str [String] A FIX message string
    # @return [Fix::Message] A +Fix::Message+ instance, or a +Fix::ParseFailure+ in case of failure
    #
    def self.parse(str)
      if ast = FixParser.new.parse(str)
        msg_klass = MessageClassMapping.get(ast.msg_type)
        
        if msg_klass
          msg = msg_klass.new(ast, str)
          (msg.errors.empty? && msg) || ParseFailure.new(msg.errors)
        else
          ParseFailure.new("Unknown message type: #{ast.msg_type}")
        end
      else
        ParseFailure.new("Failed to parse message string")
      end
    end

    #
    # Indicates whether the message successfully passed validation
    #
    # @param force [Boolean] Whether to run the validation logic even if the +errors+ collection is not empty
    # @return [Boolean] Whether the message is semantically valid
    #
    def valid?(force = false)
      (errors.nil? || force) && validate(true)
      errors.empty?
    end 

    #
    # Validates the message semantics and populates the +errors+ collection accordingly,
    # validation is performed only if the +errors+ collection 
    # is +nil+ or if the +force+ parameter is true
    #
    # @param force [Boolean] Whether to run the validation logic even if the +errors+ collection is not empty
    #
    def validate(force = false)
      if force or errors.nil?
        self.errors = []

        errors << "Unsupported version: #{version}"               unless FIX_VERSIONS.include?(version)
        errors << "Incorrect body length"                         unless Message.verify_body_length(raw)
        errors << "Incorrect sequence number: #{header_tag(34)}"  unless msg_seq_num > 0
        errors << "Incorrect sending time: #{header_tag(52)}"     unless sending_time
        errors << "Incorrect checksum"                            unless Message.verify_checksum(raw)
      end
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
      @target_comp_id = header_tag(56)
      @msg_seq_num    = header_tag(34).to_i
      @sending_time   = parse_timestamp(header_tag(52))
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

    #
    # Parses a FIX-formatted timestamp into a DateTime instance, milliseconds are discarded
    #
    # @param str [String] A FIX-formatted timestamp
    # @return [DateTime] An UTC date and time
    #
    def parse_timestamp(str)
      if m = str.match(/\A([0-9]{4})([0-9]{2})([0-9]{2})-([0-9]{2}):([0-9]{2}):([0-9]{2})(.[0-9]{3})?\Z/)
        elts = m.to_a.map(&:to_i)
        DateTime.new(elts[1], elts[2], elts[3], elts[4], elts[5], elts[6])
      end
    end

    #
    # Outputs a DateTime object as a FIX-formatted timestamp
    #
    # @param dt [DateTime] An UTC date and time
    # @return [String] A FIX-formatted timestamp
    #
    def dump_timestamp(dt)
      dt.strftime('%Y%m%d-%H:%M:%S')
    end

    #
    # Serializes an instance as a FIX message string
    #
    # @return [String] The FIX message string
    #
    def dump
      part_2  = "35=#{msg_type}\x0149=#{sender_comp_id}\x0156=#{target_comp_id}\x0134=#{msg_seq_num}\x0152=#{dump_timestamp(sending_time)}\x01#{dump_body}"
      part_1  = "8=#{version}\x019=#{part_2.length}\x01"
      chk     = '%03d' % ((part_1 + part_2).bytes.inject(&:+) % 256)

      "#{part_1}#{part_2}10=#{chk}\x01"
    end

    #
    # Returns the message body as a string
    #
    # @return [String] The body fields as a partial FIX message string
    #
    def dump_body
      body.map { |f| "#{f[0]}=#{f[1]}\x01" }.join
    end

    #
    # Returns the message type for this class
    #
    # @return [String] The message type for this message class
    #
    def msg_type
      MessageClassMapping.reverse_get(self.class)
    end

  end
end
