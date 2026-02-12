class Rtypes
  class Kotlin

    def initialize(serializer)
      @serializer = serializer
      @model = Rtypes.serializer_to_model(serializer)
    end

    def generate
      if invalid? || !generate_target?
        return
      end
      Rtypes.create_file(file_path, file_content)
    end

    def file_name
      if invalid?
        return
      end

      [
        @serializer.to_s.deconstantize.underscore,
        "#{@model.name}.kt",
      ].compact_blank.join('/')
    end

    def file_path
      "#{Rails.root.join('kotlin', file_name)}" rescue nil
    end

    def file_content
      if invalid?
        return
      end

      analyzer = Rtypes::Analyzer.new(@serializer)

      properties = analyzer.attributes.map do |attribute|
        Rtypes::Kotlin.attribute_to_property(attribute)
      end

      analyzer.associations
        .filter{ _1[:serializer].present? }
        .each do |association|
          properties << if association[:type] == :has_many
            "val #{association[:name].camelize(:lower)}: List<#{association[:class_name]}>? = null"
          else
            "val #{association[:name].camelize(:lower)}: #{association[:class_name]}? = null"
          end
        end

      if properties.empty?
        return ''
      end

      result = [
        "data class #{@model.name}(",
        Rtypes::Kotlin.indent(properties.join(",\n")),
        ")\n",
      ].join("\n" * [Rtypes.config.line_space.to_i + 1, 1].max)

      if Rtypes.config.kotlin_package_name.present?
        "package #{Rtypes.config.kotlin_package_name}\n\n#{result}"
      else
        result
      end
    end

    class << self

      def attribute_to_property(attribute)

        type_config = Rtypes.config.kotlin_types&.find{ _1[:type] == attribute[:type] }

        type = if type_config&.dig(:class).present?
          "#{type_config[:class]}? = null"
        elsif attribute[:type] == :integer
          'Int? = null'
        elsif attribute[:type] == :bigint
          'Long? = null'
        elsif attribute[:type] == :boolean
          if attribute[:null] == false
            'Boolean = false'
          else
            'Boolean? = null'
          end
        else
          'String? = null'
        end

        result = "val #{attribute[:name].camelize(:lower)}: #{type}"

        if attribute[:comment].present?
          result = "#{Rtypes::Kotlin.comment(attribute[:comment])}\n#{result}"
        end

        if type_config&.dig(:annotation).present?
          result = "#{type_config[:annotation]}\n#{result}"
        end

        result
      end

      def comment(text)
        <<~EOS.strip
        /**
         * #{text}
         */
        EOS
      end

      def indent(text)
        text.each_line.map{ "    #{_1}" }.join
      end

    end

    private

      def generate_target?
        if Rtypes.config.kotlin_root_directory.blank?
          return true
        end
        Rtypes.serializer_to_path(@serializer).start_with?(Rtypes.config.kotlin_root_directory.to_s)
      end

      def invalid?
        @serializer == nil || @model == nil
      end

  end

end

