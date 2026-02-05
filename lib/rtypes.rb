require "rtypes/version"
require "rtypes/railtie"
require "rtypes/analyzer"
require "rtypes/kotlin"
require "rtypes/type_script"

require 'listen'

class Rtypes

  class << self

    def generate(serializer)
      result = []
      result << Rtypes::TypeScript.new(serializer).generate

      if Rtypes.config.enable_kotlin == true
        result << Rtypes::Kotlin.new(serializer).generate
      end

      result.compact
    end

    def create_file(path, content)
      if path == nil
        return
      end
      if File.exists?(path) && File.read(path) == content
        return
      end
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.puts content
        f
      end
    end

    def auto_generate

      listener = Listen.to(Rails.root.join('app/serializers')) do |modified, added, removed|
        # p modified, added, removed

        if [*modified, *added].find{ _1.end_with?('.rb') && !_1.include?(' ') }
          Rails.autoloaders.main.reload rescue nil
        end

        [*modified, *added].each do |path|
          digest = Digest::SHA512.file(path).to_s

          serializer = Rtypes.path_to_serializer(path)
          files = Rtypes.generate(serializer)
          files.each do |file|
            puts "\e[32m[Update]\e[0m #{file.path}"
          end
        end

        removed.each do |path|
          delete_file_path = Rtypes.path_to_delete_file_path(path)
          if File.exist?(delete_file_path)
            FileUtils.rm_f(delete_file_path)
            puts "\e[31m[Delete]\e[0m #{delete_file_path}"
          end
        end
      end

      listener.start
    end

    def config
      @config ||= Struct.new(:path, :types, :enable_kotlin, :kotlin_package_name, :kotlin_root_directory, keyword_init: true).new(
        path: 'app/javascript/types',
        types: {
          integer: 'number',
          decimal: 'string',
          boolean: 'boolean',
        },
        enable_kotlin: false,
        kotlin_package_name: 'your.pacakge.name',
      )
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
    rescue SyntaxError => e
      nil
    end

    def serializer_to_path(serializer)
      if serializer == nil
        return
      end
      Rails.root.join('app/serializers', serializer.to_s.underscore + '.rb').to_s
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
