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
      Rails.root.join('kotlin', file_name).to_s rescue nil
    end

    def file_content
      if invalid?
        return
      end

      properties = []

      analyzer = Rtypes::Analyzer.new(@serializer)
      analyzer.attributes.each do |attribute|

        type = if attribute[:type] == :integer
          if attribute[:sql_type] == 'bigint'
            'Long? = null'
          else
            'Int? = null'
          end
        elsif attribute[:type] == :boolean
          if attribute[:null] == false
            'Boolean = false'
          else
            'Boolean? = null'
          end
        else
          'String? = null'
        end

        property = "val #{attribute[:name].camelize(:lower)}: #{type}"

        if attribute[:comment].present?
          property = "#{comment(attribute[:comment])}\n#{property}"
        end

        properties <<  property
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
        indent(properties.join(",\n")),
        ")\n",
      ].join("\n")

      if Rtypes.config.kotlin_package_name.present?
        "package #{Rtypes.config.kotlin_package_name}\n\n#{result}"
      else
        result
      end
    end

    private

      def generate_target?
        if Rtypes.config.kotlin_root_directory.blank?
          return true
        end
        Rtypes.serializer_to_path(@serializer).start_with?(Rtypes.config.kotlin_root_directory.to_s)
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

      def invalid?
        @serializer == nil || @model == nil
      end

  end

end

