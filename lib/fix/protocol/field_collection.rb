module Fix
  module Protocol

    #
    # Defines helper methods to declare and access fields on
    # the message header and body
    #
    module FieldCollection

      # Extends the class with the +has_field+ helper
      def self.included(base)
        base.extend(ClassMethods)
      end

      #
      # Returns the first value of a field in the given fields array, 
      # if the +position+ is specified then it will be enforced.
      #
      # +nil+ is returned if the field isn't found, or isn't found at the specified position
      #
      # @param part [Symbol] The fields among which the tag value should be searched, should be +:header+ or +:body+
      # @param tag [Fixnum] The tag code for which the value should be fetched
      # @param opts [Hash] The options hash, can contain +:position+ to constrain the field position, and +:type+ to force a type-cast
      # @return [Object] The type-casted value
      #
      def get_tag_value(part, tag, opts = {})
        fields    = send(part)
        position  = opts[:position]
        type      = opts[:type]
        val       = nil

        if position
          val = fields[position] && (fields[position][0] == tag) && fields[position][1]
        else
          fld = fields.find { |f| f[0] == tag }
          val = fld && fld[1]
        end

        if val && type && (type != :auto)
          send(:"parse_#{type}", val)
        else
          val
        end
      end

      #
      # Sets a field value in the relevant message part
      #
      # @param part [Symbol] The fields in which the value should be set, should be +:header+ or +:body+
      # @param tag [Fixnum] The tag code for which the value should be set
      # @param val [Object] The value to which the field should be set
      # @param opts [Hash] The options hash, can contain +:position+ to constrain the field position, and +:type+ to force a type-cast
      # @return [Object] The original value
      #
      def set_tag_value(part, tag, val, opts = {})
        raise "Can't set <nil> value for #{part} field <#{tag}>" unless val

        fields    = send(part)
        position  = opts[:position]
        type      = opts[:type]

        fields.delete_if do |i| 
          i[0] == tag
        end

        str_val = type ? send(:"dump_#{type}", val) : val

        if position
          fields.insert(position, [tag, str_val])
          fields.compact!
        else
          fields << [tag, str_val]
        end

        val
      end

      #
      # Defines class-level helpers
      #
      module ClassMethods

        #
        # Defines an accessor pair on the message class, if called on a +FP::Message+
        # subclass the field is assumed to be in the message body, otherwise it is
        # looked for in the message header
        #
        def has_field(name, opts)
          part = (self == Message) ? :header : :body

          define_method name do
            val = get_tag_value(part, opts[:tag], { position: opts[:position], type: opts[:type] })

            if !val && !raw && opts[:default]
              default_val = opts[:default].is_a?(Proc) ? opts[:default].call : opts[:default]
              val = (default_val && set_tag_value(part, opts[:tag], default_val, { position: opts[:position], type: opts[:type] }))
            end

            val
          end

          define_method "#{name}=" do |val|
            set_tag_value(part, opts[:tag], val, { position: opts[:position], type: opts[:type] })
          end

          if opts[:required]
            @required_fields ||= []
            @required_fields << name
            @required_fields.uniq!
          end
        end
      end

    end
  end
end
