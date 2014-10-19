require 'fix/protocol/type_conversions'

module Fix
  module Protocol
    class Field

      include TypeConversions

      @@attrs = [:tag, :name, :default, :type, :required, :parse_failure, :mapping]
      @@attrs.each { |attr| attr_accessor(attr) }

      def initialize(node)
        @@attrs.each { |attr| node[attr] && send("#{attr}=", node[attr]) }
        self.value ||= (default.is_a?(Proc) ? default.call(self) : default)
      end

      def dump
        "#{tag}=#{@value}\x01"
      end

      def parse(str)
        if str.match(/^#{tag}\=([^\x01]+)\x01/)
          @value = $1
          str.gsub(/^[^\x01]+\x01/, '')
        else
          self.parse_failure = "Expected <#{str}> to start with <#{tag}=...|>"  
        end
      end

      def value
        to_type(@value)
      end

      def value=(v)
        @value = from_type(v)
      end

      def raw_value
        @value
      end

      def raw_value=(v)
        @value = v
      end

      def from_type(obj)
        if obj && type && !mapping
          send("dump_#{type}", obj)
        elsif obj && mapping && mapping.has_key?(obj)
          m = mapping.find { |k,v| v == obj }
          m && m[0]
        else
          obj
        end
      end

      def to_type(val)
        if val && type && val.is_a?(String) && !mapping
          send("parse_#{type}", val)
        elsif val && mapping && mapping.values.map(&:to_s).include?(val)
          mapping[val]
        else
          val
        end
      end

      def errors
        if required && !value
          "Missing value for <#{name}> field"
        end
      end

    end
  end
end
