require "rtypes/version"
require "rtypes/railtie"

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

    @serializer._attributes_data.each do |name, attribute|
      column = @model.columns.find{ _1.name == name.to_s }
      column_type = attribute.options[:typescript] || column&.type

      type = if column_type.class == String
        column_type
      elsif self.class.config.types.has_key?(column_type)
        self.class.config.types[column_type]
      else
        'string'
      end

      properties << "#{name.to_s.camelize(:lower)}: #{type}"
    end

    other_classes = []

    @serializer._reflections.each do |name, reflection|
      class_name = @model._reflections.with_indifferent_access[name].class_name

      other_classes << class_name
      if reflection.class == ActiveModel::Serializer::BelongsToReflection || reflection.class == ActiveModel::Serializer::HasOneReflection
        properties << "#{name.to_s.camelize(:lower)}?: #{class_name}"
      elsif reflection.class == ActiveModel::Serializer::HasManyReflection
        properties << "#{name.to_s.camelize(:lower)}?: Array<#{class_name}>"
      end
    end

    result = [
      "type #{@model.name} = {",
      *properties.map{ "  #{_1}" },
      "}\n",
      "export default #{@model.name}\n"
    ]

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
