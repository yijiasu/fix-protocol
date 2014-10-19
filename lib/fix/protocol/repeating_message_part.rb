require 'fix/protocol/message_part'

module Fix
  module Protocol
    class RepeatingMessagePart < MessagePart

      extend Forwardable
      def_delegators :nodes, :[], :first, :last, :length, :size, :each

      include Enumerable

      attr_accessor :counter_tag, :element_klass

      def initialize(opts = {})
        @counter_tag    = opts[:counter_tag]
        @element_klass  = opts[:klass]
        super
      end

      def build
        nodes << element_klass.new

        if block_given?
          yield(nodes.last)
        end

        nodes.last
      end

      def dump
        "#{counter_tag}=#{length}\x01#{super}"
      end

      def parse(str)
        if str.match(/^#{counter_tag}\=([^\x01]+)\x01/)
          len = $1.to_i 
          @nodes = []
          len.times { @nodes << element_klass.new }
          super(str.gsub(/^#{counter_tag}\=[^\x01]+\x01/, ''))
        else
          self.parse_failure = "Expected <#{str}> to begin with <#{counter_tag}=...|>"
        end
      end

    end
  end
end
