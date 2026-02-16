class Rtypes
  class TypeScript

    def initialize(serializer)
      @serializer = serializer
      @model = Rtypes.serializer_to_model(serializer)

      @associations = Rtypes::Analyzer.new(@serializer).associations

      if @associations.present?

        @associations
          .filter{ _1[:serializer].present? }
          .group_by{ _1[:class_name] }.each do |class_name, associations|
            serializers = associations.map{ _1[:serializer] }.uniq
            if 1 < serializers.size
              associations.each{ _1[:import_name] = "#{_1[:class_name]}#{serializers.index(_1[:serializer]) + 1}" }
            else
              associations.each{ _1[:import_name] = _1[:class_name] }
            end
          end

        @associations.each do |association|
          association[:module_name] = module_name(association[:serializer])
        end

      end

    end

    def generate
      if invalid?
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
        "#{@model.name}.ts",
      ].compact_blank.join('/')
    end

    def file_path
      "#{Rails.root.join(Rtypes.config.path, file_name)}" rescue nil
    end

    def file_content
      if invalid?
        return
      end

      [
        import_content,
        type_content,
        export_content,
      ].compact_blank.join("\n\n") + "\n"
    end

    def import_content
      @associations
        .filter{ _1[:module_name].present? }
        .map{ "import #{_1[:import_name]} from '#{_1[:module_name]}'"}
        .uniq
        .join("\n")
    end

    def type_content
      properties = Rtypes::Analyzer.new(@serializer).attributes.map do |attribute|
        Rtypes::TypeScript.attribute_to_property(attribute)
      end

      @associations.each do |association|
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

      [
        "type #{@model.name} = {",
        *properties.map{ _1.indent(2) },
        "}",
      ].join(Rtypes.line_break)
    end

    def export_content
      "export default #{@model.name}"
    end

    class << self

      def attribute_to_property(attribute)
        type = if attribute.dig(:options, :typescript).present?
          attribute.dig(:options, :typescript)
        elsif Rtypes.config.types.has_key?(attribute[:type])
          Rtypes.config.types[attribute[:type]]
        else
          'string'
        end

        result =  "#{attribute[:name].camelize(:lower)}: #{type}"

        if attribute[:comment].present?
          result = "#{Rtypes::TypeScript.comment(attribute[:comment])}\n#{result}"
        end

        result
      end

      def comment(text)
        [
          '/**',
          *text.lines.map{ " * #{_1.strip}" },
          ' */',
        ].join("\n")
      end

    end

    private

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
        elsif import_depth < own_depth
          "#{'../' * (own_depth - import_depth)}#{model.name}"
        end
      end

      def invalid?
        @serializer == nil || @model == nil
      end

  end

end

