module Fix
  module Protocol
    class Field

      @@attrs = [:tag, :value, :name, :default, :type, :required, :parse_failure]
      @@attrs.each { |attr| attr_accessor(attr) }

      def initialize(node)
        @@attrs.each { |attr| node[attr] && send("#{attr}=", node[attr]) }
        self.value ||= (default.is_a?(Proc) ? default.call(self) : default)
      end

      def dump
        "#{tag}=#{value}\x01"
      end

      def parse(str)
        if str.match(/^#{tag}\=([^\x01]+)\x01/)
          self.value = $1
          str.gsub(/^[^\x01]+\x01/, '')
        else
          self.parse_failure = "Expected <#{str}> to start with <#{tag}=...|>"  
        end
      end

    end
  end
end
