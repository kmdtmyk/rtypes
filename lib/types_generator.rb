require "types_generator/version"
require "types_generator/railtie"

class TypesGenerator

  def initialize(name)
    @name = name
  end

  def generate
    FileUtils.mkdir_p(File.dirname(file_path))
    File.new(file_path, 'w').puts(file_content)
  end

  def file_name
    "#{@name}.ts"
  end

  def file_path
    Rails.root.join(TypesGenerator.config.path, file_name).to_s
  end

  def file_content
    model = @name.constantize
    serializer = "#{@name}Serializer".constantize

    result = ["type #{@name} = {"]

    serializer._attributes_data.each do |name, attribute|
      column = model.columns.find{ _1.name == name.to_s }
      column_type = attribute.options[:typescript] || column&.type

      type = if name.end_with?('id')
        "number | null"
      elsif column_type == :integer
        "number | string"
      elsif column_type == :decimal
        "number | string"
      else
        "string"
      end

      result <<  "  #{name.to_s.camelize(:lower)}: #{type}"
    end

    other_classes = []

    serializer._reflections.each do |name, reflection|
      class_name = model._reflections.with_indifferent_access[name].class_name
      other_classes << class_name
      if reflection.class == ActiveModel::Serializer::BelongsToReflection
        result << "  #{name.to_s.camelize(:lower)}?: #{class_name}"
      elsif reflection.class == ActiveModel::Serializer::HasManyReflection
        result << "  #{name.to_s.camelize(:lower)}?: Array<#{class_name}>"
      end
    end

    result << "}\n"
    result << "export default #{@name}"
    result << ''

    imports = []
    if other_classes.present?
      other_classes.uniq.each do |class_name|
        imports << "import #{class_name} from './#{class_name}'"
      end
      imports << ''
    end

    (imports + result).join("\n")
  end

  class << self

    def config
      @config ||= Struct.new(:path, keyword_init: true).new(
        path: 'app/javascript/types',
      )
    end

  end

end
