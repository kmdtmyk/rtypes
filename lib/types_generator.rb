# frozen_string_literal: true

require_relative "types_generator/railtie"
require_relative "types_generator/version"

class TypesGenerator
  class Error < StandardError; end
  # Your code goes here...

  def initialize(name)
    @name = name
  end

  def file_name
    "#{@name}.ts"
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
      class_name = model._reflections[name.to_s].class_name
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

end
