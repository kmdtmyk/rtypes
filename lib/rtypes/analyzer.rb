
class Rtypes
  class Analyzer

    def initialize(serializer)
      @serializer = serializer
      @model = Rtypes.serializer_to_model(serializer)
    end

    def attributes
      if @model == nil
        return
      end

      @serializer._attributes_data.map do |name, attribute|
        column = @model.columns.find{ _1.name == name.to_s }
        result = {
          name: name.to_s,
          type: column&.type,
          comment: column&.comment,
        }

        if result[:type] == :integer && column&.sql_type == 'bigint'
          result[:type] = :bigint
        end

        if result[:type] == :boolean || result[:type] == :string
          result[:null] = column&.null
        end

        if attribute.options.present?
          result[:options] = attribute.options
        end
        result
      end
    end

    def associations
      if @model == nil
        return
      end

      model_reflections = @model._reflections.with_indifferent_access

      @serializer._reflections.map do |name, reflection|
        model_reflection = model_reflections[name]
        if model_reflection == nil
          next
        end

        type = if reflection.class == ActiveModel::Serializer::BelongsToReflection
          :belongs_to
        elsif reflection.class == ActiveModel::Serializer::HasOneReflection
          :has_one
        elsif reflection.class == ActiveModel::Serializer::HasManyReflection
          :has_many
        end

        class_name = model_reflection.class_name

        serializer = reflection.dig(:options, :serializer) || "#{@serializer}::#{class_name}Serializer".safe_constantize || "#{class_name}Serializer".safe_constantize

        {
          type: type,
          name: name.to_s,
          class_name: class_name,
          serializer: serializer,
        }
      end.compact
    end

    def nested_serializers
      Rtypes.all_serializers
        .filter{ _1.to_s.start_with?("#{@serializer.to_s}::") }
        .sort{ _1.to_s.count(':') }
    end

    def parent_serializer
      Rtypes.all_serializers.find do |serializer|
        serializer.to_s == @serializer.to_s.deconstantize
      end
    end

  end

end

