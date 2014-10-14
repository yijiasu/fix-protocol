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

      def initialize
        super
        associated_groups.each do |g| 
          groups[g] = []
        end
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

      def groups
        @groups ||= {}
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
            if opts[:mapping] && opts[:mapping].is_a?(Hash)
              v = opts[:mapping][val] || raise("Incorrect value <#{val}> for attribute <#{name}>")
            else
              v = val
            end


            set_tag_value(part, opts[:tag], v, { position: opts[:position], type: opts[:type] })
          end

          if opts[:required]
            @required_fields ||= []
            @required_fields << name
            @required_fields.uniq!
          end
        end

        def has_repeating_group(name, opts = {})
          associated_groups[opts[:counter]] = {
            name: name,
            opts: opts
          }

          mapping = associated_groups[opts[:counter]][:opts][:mapping]
          if mapping

            mapping = mapping.inject({}) do |h,i| 
              h[i[0]] = i[1].to_s
              h
            end

            associated_groups[opts[:counter]][:opts][:mapping] = mapping
          end

          define_method name do 
            groups[opts[:counter]] ||= []

            if opts[:mapping]
              groups[opts[:counter]].map do |i|
                m = opts[:mapping].find { |k,v| v == i.to_s }
                mapped = m && m[0]
                mapped || i
              end.freeze
            else
              groups[opts[:counter]]
            end
          end

          define_method "#{name}=" do |val|
            if opts[:mapping]
              groups[opts[:counter]] = [val].flatten.map do |i|
                opts[:mapping][i] || opts[:mapping][i.to_s] || i.to_s
              end
            else
              groups[:opts[:mapping]] = [val].flatten
            end
          end

          define_method "raw_#{name}" do
            groups[opts[:counter]]
          end

          define_method "raw_#{name}=" do |val|
            groups[opts[:counter]] = [val].flatten
          end
        end

        def associated_groups
          @groups ||= {}
        end

      end
    end
  end
end
