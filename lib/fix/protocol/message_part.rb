require 'fix/protocol/field'

module Fix
  module Protocol
    class MessagePart

      attr_accessor :parse_failure, :name

      def initialize(opts = {})
        self.name = opts[:name]
        self.class.structure.each { |node| initialize_node(node) }
      end

      def self.inherited(klass)
        klass.send(:instance_variable_set, :@structure, structure.dup)
      end

      def dump
        nodes.map(&:dump).join
      end

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

      def initialize_node(node)
        if node[:node_type] == :part
          nodes << node[:klass].new(node)
        elsif node[:node_type] == :field
          nodes << FP::Field.new(node)
        elsif node[:node_type] == :collection
          nodes << FP::RepeatingMessagePart.new(node)
        end
      end

      def nodes
        @nodes ||= []
      end

      def node_for_name(n)
        nodes.find { |node| node.name.to_s == n.to_s }
      end

      def self.parse(str)
        instce = new
        instce.parse(str)
        instce
      end

      def self.collection(name, opts = {})
        structure << { node_type: :collection, name: name, counter_tag: opts[:counter_tag], klass: opts[:klass] }

        define_method(name) do
          node_for_name(name)
        end
      end

      def self.part(name, opts = {})
        structure << { node_type: :part, name: name }.merge(opts)

        define_method(name) do
          node_for_name(name)
        end
      end

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

      def self.structure
        @structure ||= []
      end

      def errors
        nodes.map(&:errors).flatten.compact
      end


    end
  end
end

