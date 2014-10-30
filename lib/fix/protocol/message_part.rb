require 'fix/protocol/field'

module Fix
  module Protocol

    #
    # Basic building block for messages. Message parts can define fields, sub-parts and collections
    #
    class MessagePart

      attr_accessor :parse_failure, :name

      def initialize(opts = {})
        self.name = opts[:name]
        self.class.structure.each { |node| initialize_node(node) }
      end

      #
      # Inherits the +@structure+ class instance variable but allows
      # the child to modify it without impacting the parent, this allows
      # for message structure refinement
      #
      def self.inherited(klass)
        klass.send(:instance_variable_set, :@structure, structure.dup)
      end

      #
      # Dumps this message part as a FIX message fragment
      #
      # @return [String] A FIX message fragment
      #
      def dump
        nodes.map(&:dump).join
      end

      #
      # Parses a full or partial FIX message string into the message part nodes
      #
      # @return [String] The string part that wasn't consumed during the parsing
      #
      def parse(str)
        left_to_parse = str

        nodes.each do |node|
          unless parse_failure
            left_to_parse = node.parse(left_to_parse)
            self.parse_failure = node.parse_failure
          end
        end

        left_to_parse
      end

      #
      # Initializes a node depending on its type, this is called when initializing a message
      # part instance by the constructor. Usually one node is initialized for each structure element
      #
      def initialize_node(node)
        if node[:node_type] == :part
          nodes << node[:klass].new(node)
        elsif node[:node_type] == :field
          nodes << FP::Field.new(node)
        elsif node[:node_type] == :collection
          nodes << FP::RepeatingMessagePart.new(node)
        elsif node[:node_type] == :unordered
          nodes << node[:klass].new(node)
        end
      end

      #
      # The message part nodes, they'll be either a +FP::Field+, an +FP::RepeatingMessagePart+ or a +FP::MessagePart+
      #
      # @return [Array] The nodes for this message part
      #
      def nodes
        @nodes ||= []
      end

      #
      # Searches the immediate hierarchy by node name to return the requested node
      #
      # @param n [String] The node name to look for
      # @return [Object] The found node, if any
      #
      def node_for_name(n)
        nodes.find { |node| node.name.to_s == n.to_s }
      end

      #
      # Class-level shortcut to directly parse an instance of a specific message part subclass
      #
      def self.parse(str)
        instce = new
        instce.parse(str)
        instce
      end

      #
      # Defines a collection as a part of this message part, collections typically have a counter and a repeating element
      #
      # @param name [String] The collection name, this will be the name of a dynamically created accessor on the message part
      # @param opts [Hash] The required options are +:counter_tag+ and +:klass+
      #
      def self.collection(name, opts = {})
        structure << { node_type: :collection, name: name, counter_tag: opts[:counter_tag], klass: opts[:klass] }

        define_method(name) do
          node_for_name(name)
        end
      end

      #
      # Defines a reusable message part as element of this particular class
      #
      # @param name [String] The part name, this will be the name of a dynamically created accessor on the message part
      # @param opts [Hash] Options hash
      #
      def self.part(name, opts = {})
        structure << { node_type: :part, name: name }.merge(opts)

        define_method(name) do
          node_for_name(name)
        end
      end

      #
      # Defines an unordered fields collection
      #
      # @param name [String] The part name, this will be the name of a dynamically created accessor on the message part
      # @param opts [Hash] Options hash
      #
      def self.unordered(name, opts = {})
        part(name, opts.merge({ node_type: :unordered }))
      end


      #
      # Defines a field as part of the structure for this class
      #
      # @param name [String] The field name, this will be the base name of a set of methods created on the class instances
      # @param opts [Hash] Options hash
      #
      def self.field(name, opts)
        structure << { node_type: :field, name: name }.merge(opts)

        # Getter
        define_method(name) do
          node_for_name(name).value
        end

        # Setter
        define_method("#{name}=") do |val|
          node_for_name(name).value = val
        end

        if opts[:mapping]
          define_method("raw_#{name}") do
            node_for_name(name).raw_value
          end

          define_method("raw_#{name}=") do |val|
            node_for_name(name).raw_value = val
          end
        end
      end

      #
      # Returns this message part class' structure
      #
      # @return [Array] The message structure
      #
      def self.structure
        @structure ||= []
      end

      #
      # Returns the errors for this instance
      # 
      # @return [Array] The errors for this instance
      #
      def errors
        [nodes.map(&:errors), nodes.map(&:parse_failure)].flatten.compact
      end

    end
  end
end

