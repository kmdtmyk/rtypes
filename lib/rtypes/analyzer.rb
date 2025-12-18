
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
          name: name,
        }
        if attribute.options.present?
          result[:options] = attribute.options
        end
        result
      end
    end

  end

end

