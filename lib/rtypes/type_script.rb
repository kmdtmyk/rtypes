class Rtypes
  class TypeScript

    def initialize(serializer)
      @serializer = serializer
      @model = Rtypes.serializer_to_model(serializer)
    end

    def generate
      if invalid?
        return
      end
      FileUtils.mkdir_p(File.dirname(file_path))
      File.open(file_path, 'w') do |f|
        f.puts file_content
        f
      end
    end

    def file_name
      if invalid?
        return
      end

      [
        @serializer.to_s.deconstantize.underscore,
        "#{@model.name}.ts",
      ].compact_blank.join('/')
    end

    def file_path
      Rails.root.join(Rtypes.config.path, file_name).to_s rescue nil
    end

    def file_content
      if invalid?
        return
      end

      properties = []

      analyzer = Rtypes::Analyzer.new(@serializer)
      analyzer.attributes.each do |attribute|

        type = if attribute.dig(:options, :typescript).present?
          attribute.dig(:options, :typescript)
        elsif Rtypes.config.types.has_key?(attribute[:type])
          Rtypes.config.types[attribute[:type]]
        else
          'string'
        end

        property =  "#{attribute[:name].camelize(:lower)}: #{type}"

        if attribute[:comment].present?
          property = "#{comment(attribute[:comment])}\n#{property}"
        end

        properties <<  property
      end

      associations = analyzer.associations

      associations
        .filter{ _1[:serializer].present? }
        .group_by{ _1[:class_name] }.each do |class_name, associations|
          serializers = associations.map{ _1[:serializer] }.uniq
          if 1 < serializers.size
            associations.each{ _1[:import_name] = "#{_1[:class_name]}#{serializers.index(_1[:serializer]) + 1}" }
          else
            associations.each{ _1[:import_name] = _1[:class_name] }
          end
        end

      associations.each do |association|
        association[:module_name] = module_name(association[:serializer])
      end

      associations.each do |association|
        type = if association[:serializer].present?
          association[:import_name]
        else
          'any'
        end

        if association[:type] == :has_many
          properties << "#{association[:name].camelize(:lower)}?: Array<#{type}>"
        else
          properties << "#{association[:name].camelize(:lower)}?: #{type}"
        end
      end

      result = [
        "type #{@model.name} = {",
        indent(properties.join("\n")),
        "}\n",
        "export default #{@model.name}\n"
      ]

      imports = associations
        .filter{ _1[:module_name].present? }
        .map{ "import #{_1[:import_name]} from '#{_1[:module_name]}'"}
        .uniq

      if imports.present?
        imports << ''
      end

      (imports + result).join("\n")
    end

    private

      def comment(text)
        <<~EOS.strip
        /**
         * #{text}
         */
        EOS
      end

      def indent(text)
        text.each_line.map{ "  #{_1}" }.join
      end

      def serializer_depth(serializer)
        serializer.to_s.split('::').size
      end

      def module_name(serializer)
        if serializer.nil?
          return
        end
        own_depth = serializer_depth(@serializer)
        import_depth = serializer_depth(serializer)
        model = Rtypes.serializer_to_model(serializer)
        if own_depth == import_depth
          "./#{model.name}"
        else
          "#{'../' * (own_depth - import_depth)}#{model.name}"
        end
      end

      def invalid?
        @serializer == nil || @model == nil
      end

  end

end

