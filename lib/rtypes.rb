require "rtypes/version"
require "rtypes/railtie"
require "rtypes/analyzer"

class Rtypes

  def initialize(name)
    if name.class == Class && name.superclass == ActiveModel::Serializer
      @model = name.to_s.split('::').last.delete_suffix('Serializer').constantize
      @serializer = name
    else
      @model = name.classify.constantize
      @serializer = "#{name.classify}Serializer".constantize
    end
  rescue NameError => e
    raise %(Error: Invalid model name "#{name}")
  end

  def generate
    FileUtils.mkdir_p(File.dirname(file_path))
    File.new(file_path, 'w').puts(file_content)
  end

  def file_name
    [
      @serializer.to_s.deconstantize.underscore,
      "#{@model.name}.ts",
    ].compact_blank.join('/')
  end

  def file_path
    Rails.root.join(Rtypes.config.path, file_name).to_s
  end

  def file_content

    properties = []

    analyzer = Rtypes::Analyzer.new(@serializer)
    analyzer.attributes.each do |attribute|

      type = if attribute.dig(:options, :typescript).present?
        attribute.dig(:options, :typescript)
      elsif self.class.config.types.has_key?(attribute[:type])
        self.class.config.types[attribute[:type]]
      else
        'string'
      end

      properties << "#{attribute[:name].camelize(:lower)}: #{type}"
    end

    analyzer.associations.each do |association|
      type = if association[:serializer].present?
        association[:class_name]
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
      *properties.map{ "  #{_1}" },
      "}\n",
      "export default #{@model.name}\n"
    ]

    other_classes = analyzer.associations
      .filter{ _1[:serializer].present? }
      .map{ _1[:class_name] }

    imports = other_classes.map{ import_statement(_1) }.uniq
    if imports.present?
      imports << ''
    end

    (imports + result).join("\n")
  end

  private

    def serializer_depth(serializer)
      serializer.to_s.split('::').size
    end

    def import_statement(class_name)
      own_depth = serializer_depth(@serializer)
      import_depth = serializer_depth(find_serializer(class_name))
      if own_depth == import_depth
        "import #{class_name} from './#{class_name}'"
      else
        "import #{class_name} from '#{'../' * (own_depth - import_depth)}#{class_name}'"
      end
    end

    def find_serializer(class_name)
      namespaces = @serializer.to_s.deconstantize.split('::')
      serialize_names = (0..namespaces.size).map do |i|
        [
          *namespaces[0...i],
          "#{class_name}Serializer",
        ].join('::')
      end
      serializers = serialize_names.map{ _1.safe_constantize }
      serializers.compact.last
    end

  class << self

    def config
      @config ||= Struct.new(:path, :types, keyword_init: true).new(
        path: 'app/javascript/types',
        types: {
          integer: 'number',
          decimal: 'string',
          boolean: 'boolean',
        },
      )
    end

    def config_file_content
      config.to_h.map do |name, value|
        if value.class == Hash
          value = [
            '{',
            *value.map{ "  #{_1}: '#{_2}',"},
            '}',
          ].join("\n")
        else
          value = "'#{value}'"
        end
        "#{Rtypes}.config.#{name} = #{value}"
      end.join("\n")
    end

    def all_serializers
      Dir.glob(Rails.root.join('app/serializers/**/*.rb')).each{ |f| load f }
      ActiveModel::Serializer.descendants - [ActiveModel::Serializer::ErrorSerializer]
    end

  end

end
