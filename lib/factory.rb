# frozen_string_literal: true

class Factory
  def self.new(*attributes, &block)
    clazz = Class.new do
      attr_accessor(*attributes)

      def initialize(*values)
        self.class::ATTRIBUTES.each_with_index do |attribute, index|
          instance_variable_set(:"@#{attribute}", values[index])
        end
      end

      def ==(other)
        return false unless self.class == other.class

        self.class::ATTRIBUTES.all? do |attribute|
          value1 = public_send(attribute)
          value2 = other.public_send(attribute)

          value1 == value2
        end
      end

      def [](key)
        send("instance_variable_get_by_#{key.is_a?(Integer) ? 'index' : 'name'}", key)
      end

      def []=(key, value)
        send("instance_variable_set_by_#{key.is_a?(Integer) ? 'index' : 'name'}", key, value)
      end

      # set constant with attrs names
      # that will be used in constructor
      const_set('ATTRIBUTES', attributes)

      private

      def instance_variable_get_by_name(name)
        public_send(name.to_sym)
      end

      def instance_variable_set_by_name(name, value)
        public_send(:"#{name}=", value)
      end

      def instance_variable_get_by_index(index)
        name = self.class::ATTRIBUTES[index]
        instance_variable_get_by_name(name)
      end

      def instance_variable_set_by_index(index, value)
        name = self.class::ATTRIBUTES[index]
        instance_variable_set_by_name(name, value)
      end
    end

    # evaluetes block on class level
    clazz.class_eval(&block) if block

    clazz
  end
end
