module Fix
  module Protocol
    class MessagePart

      attr_accessor :parse_failure

      def initialize
        self.class.structure.each { |node| initialize_node(node) }
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
      end

      def initialize_node(node)
        nodes << FP::Field.new(node)
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

      def self.field(name, opts)
        structure << { name: name }.merge(opts)

        # Getter
        define_method(name) do
          node_for_name(name).value
        end

        define_method("#{name}=") do |val|
          node_for_name(name).value = val
        end
      end

      def self.structure
        @structure ||= []
      end

    end
  end
end

