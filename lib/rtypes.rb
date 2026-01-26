require "rtypes/version"
require "rtypes/railtie"
require "rtypes/analyzer"
require "rtypes/type_script"

require 'listen'

class Rtypes

  class << self

    def generate(serializer)
      Rtypes::TypeScript.new(serializer).generate
    end

    def auto_generate

      listener = Listen.to(Rails.root.join('app/serializers')) do |modified, added, removed|
        # p modified, added, removed

        if [*modified, *added].find{ _1.end_with?('.rb') }
          Rails.autoloaders.main.reload
        end

        [*modified, *added].each do |path|
          serializer = Rtypes.path_to_serializer(path)
          file = Rtypes.generate(serializer)
          if file != nil
            puts file.path
          end
        end

        removed.each do |path|
          FileUtils.rm(path_to_delete_file_path(path), force: true)
        end
      end

      listener.start
    end

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
      content = config.to_h.map do |name, value|
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

      content += "\n" * 2

      content += <<~EOS
        if Rails.env.development?
          Rtypes.auto_generate
        end
      EOS

      content
    end

    def all_serializers
      Dir.glob(Rails.root.join('app/serializers/**/*.rb')).each{ |f| load f }
      ActiveModel::Serializer.descendants - [ActiveModel::Serializer::ErrorSerializer]
    end

    def serializer_to_model(serializer)
      serializer.to_s.split('::').last.delete_suffix('Serializer').safe_constantize rescue nil
    end

    def name_to_serializer(name)
      if name == nil
        return
      end

      if name.end_with?('Serializer')
        name.safe_constantize
      else
        "#{name.classify}Serializer".safe_constantize
      end
    end

    def path_to_serializer(path)
      path.split('app/serializers/').last.delete_suffix('.rb').classify.safe_constantize rescue nil
    end

    def path_to_delete_file_path(path)
      if path == nil
        return
      end

      path
        .gsub('app/serializers', Rtypes.config.path)
        .gsub(File.basename(path), File.basename(path, '_serializer.rb').classify + '.ts')
    end

  end

end
