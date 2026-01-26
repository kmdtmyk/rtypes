require "rtypes/version"
require "rtypes/railtie"
require "rtypes/analyzer"

class Rtypes

  def initialize(serializer)
    @serializer = serializer
    @model = serializer.to_s.split('::').last.delete_suffix('Serializer').constantize
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

    associations = analyzer.associations

    associations
      .filter{ _1[:serializer].present? }
      .group_by{ _1[:class_name] }.each do |class_name, associations|
        serialiers = associations.map{ _1[:serializer] }.uniq
        if 1 < serialiers.size
          associations.each{ _1[:import_name] = "#{_1[:class_name]}#{serialiers.index(_1[:serializer]) + 1}" }
        else
          associations.each{ _1[:import_name] = _1[:class_name] }
        end
      end

    associations.each do |association|
      association[:module_name] = module_name(association[:class_name], association[:serializer])
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
      *properties.map{ "  #{_1}" },
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

    def serializer_depth(serializer)
      serializer.to_s.split('::').size
    end

    def module_name(class_name, serializer)
      if serializer.nil?
        return
      end
      own_depth = serializer_depth(@serializer)
      import_depth = serializer_depth(serializer)
      if own_depth == import_depth
        "./#{class_name}"
      else
        "#{'../' * (own_depth - import_depth)}#{class_name}"
      end
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

    def name_to_serializer(name)
      if name != nil
        "#{name.classify}Serializer".safe_constantize
      end
    end

  end

end
