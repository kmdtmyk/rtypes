
class Rtypes
  class Analyzer

    def initialize(serializer)
      @serializer = serializer
      @model = serializer.to_s.split('::').last.delete_suffix('Serializer').constantize
    end

    def attributes
      @serializer._attributes_data.map do |name, attribute|
        column = @model.columns.find{ _1.name == name.to_s }
        result = {
          type: column&.type,
          name: name.to_s,
        }
        if attribute.options.present?
          result[:options] = attribute.options
        end
        result
      end
    end

    def associations
      @serializer._reflections.map do |name, reflection|
        class_name = @model._reflections[name.to_s].class_name
        type = if reflection.class == ActiveModel::Serializer::BelongsToReflection
          :belongs_to
        elsif reflection.class == ActiveModel::Serializer::HasOneReflection
          :has_one
        elsif reflection.class == ActiveModel::Serializer::HasManyReflection
          :has_many
        end

        serializer = reflection.dig(:options, :serializer) || "#{class_name}Serializer".safe_constantize

        {
          type: type,
          name: name.to_s,
          class_name: class_name,
          serializer: serializer,
        }
      end
    end

  end

end

