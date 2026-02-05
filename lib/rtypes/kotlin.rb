class Rtypes
  class Kotlin

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
        "#{@model.name}.kt",
      ].compact_blank.join('/')
    end

    def file_path
      Rails.root.join('kotlin', file_name).to_s rescue nil
    end

    def file_content
      if invalid?
        return
      end

      properties = []

      analyzer = Rtypes::Analyzer.new(@serializer)
      analyzer.attributes.each do |attribute|

        type = if attribute[:type] == :integer
          'Int'
        else
          'String'
        end

        property =  "val #{attribute[:name].camelize(:lower)}: #{type}? = null"

        if attribute[:comment].present?
          property = "#{comment(attribute[:comment])}\n#{property}"
        end

        properties <<  property
      end

      [
        "data class #{@model.name}(",
        indent(properties.join(",\n")),
        ")\n",
      ].join("\n")
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
        text.each_line.map{ "    #{_1}" }.join
      end

      def invalid?
        @serializer == nil || @model == nil
      end

  end

end

