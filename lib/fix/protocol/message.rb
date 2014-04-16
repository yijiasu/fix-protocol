require 'polyglot'
require 'treetop'

require 'fix/protocol/field_collection'
require 'fix/protocol/grammar'
require 'fix/protocol/message_class_mapping'
require 'fix/protocol/parse_failure'
require 'fix/protocol/type_conversions'

module Fix
  module Protocol

    #
    # Represents an instance of a FIX message
    #
    class Message

      include TypeConversions
      include FieldCollection

      #
      # The known FIX versions that will be parsed
      #
      FIX_VERSIONS = %w{ 4.1 4.2 4.4 }.map { |v| "FIX.#{v}" }

      has_field :version,         tag: 8,   required: true,   position: 0,                    default: 'FIX.4.4'
      has_field :body_length,     tag: 9,   required: true,   position: 1,  type: :auto
      has_field :msg_type,        tag: 0,   required: true,   position: 2,  type: :auto
      has_field :sender_comp_id,  tag: 49,  required: true
      has_field :target_comp_id,  tag: 56,  required: true
      has_field :sending_time,    tag: 52,  required: true,                 type: :timestamp, default: proc { Time.now }
      has_field :msg_seq_num,     tag: 34,  required: true,                 type: :integer

      attr_accessor :raw, :header, :body, :checksum, :errors

      def initialize
        @body   ||= []
        @header ||= []
      end

      #
      # Instantiates a +Fix::Protocol::Message+ instance from an AST and the raw form
      # of a FIX message
      #
      # @param ast [Fix::Protocol::GrammarExtensions::Message] The parsed AST
      # @param str [String] The raw message
      # @return [Fix::Protocol::Message] A message instance
      #
      def self.from_ast(ast, str)
        msg = new

        # TODO : Correctly override values
        msg.header   = ast.header
        msg.body     = ast.body
        msg.raw      = str

        msg.validate

        msg
      end

      #
      # Parses a string into a Fix::Protocol::Message instance
      #
      # @param str [String] A FIX message string
      # @return [Fix::Protocol::Message] A +Fix::Protocol::Message+ instance, or a +Fix::Protocol::ParseFailure+ in case of failure
      #
      def self.parse(str)
        if ast = FixParser.new.parse(str)
          msg_klass = MessageClassMapping.get(ast.msg_type)

          if msg_klass
            msg = msg_klass.from_ast(ast, str)
            (msg.errors.empty? && msg) || ParseFailure.new(msg.errors, msg)
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

          errors << "Unsupported version: #{version}" unless FIX_VERSIONS.include?(version)
          errors << "Incorrect body length"           unless raw.nil? || Message.verify_body_length(raw)
          errors << "Incorrect sequence number"       unless msg_seq_num && msg_seq_num > 0
          errors << "Incorrect sending time"          unless sending_time
          errors << "Incorrect checksum"              unless raw.nil? || Message.verify_checksum(raw)

          required_fields.each do |name|
            val = send(name)
            errors << "Missing value for <#{name}> field" if (val.nil? || (val.is_a?(String) && val.chomp == ""))
          end
        end
      end

      #
      # Returns the fields marked as mandatory on the class itself and on the +FP::Message+ class
      #
      # @return [Array<Symbol>] The required fields names
      #
      def required_fields
        [self.class, Message].inject([]) do |flds, klass|
          flds += klass.instance_variable_get(:@required_fields) || []
        end.uniq
      end

      #
      # Verifies that the checksum of this message is correct
      #
      # @param str [String] The raw FIX message
      # @return [Boolean] Whether the checksum is correct
      #
      def self.verify_checksum(str)
        chk = (str && str.match(/10=([^\x01]+)\x01\Z/)[1])

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
        if str && (m = str.match(/\A8=[^\x01]+\x019=([^\x01]+)\x01(.*)10=[0-9]{3}\x01\Z/))
          expected  = m[1].to_i
          actual    = m[2].length
          expected  == actual
        end
      end

      #
      # Serializes an instance as a FIX message string
      #
      # @return [String] The FIX message string
      #
      def dump
        if valid?(true)
          part_2  = "35=#{msg_type}\x0149=#{sender_comp_id}\x0156=#{target_comp_id}\x0134=#{msg_seq_num}\x0152=#{dump_timestamp(sending_time)}\x01#{dump_body}"
          part_1  = "8=#{version}\x019=#{part_2.length}\x01"
          chk     = '%03d' % ((part_1 + part_2).bytes.inject(&:+) % 256)

          "#{part_1}#{part_2}10=#{chk}\x01"
        end
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
end
