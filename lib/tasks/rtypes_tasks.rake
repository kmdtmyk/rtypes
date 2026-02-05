namespace :rtypes do

  desc 'Add configuration file'
  task :install do
    file_path = Rails.root.join('config/initializers/rtypes.rb').to_s
    FileUtils.cp(File.expand_path('../templates/initializer.rb', __FILE__), file_path)
    puts "\e[32m[Create]\e[0m #{file_path}"
  end

  desc 'Generate typescript definition file'
  task :generate, [:name] => :environment do |task, args|

    serializers = if args[:name].present?
      serializer = Rtypes.name_to_serializer(args[:name])
      if serializer.nil?
        raise %(Error: Invalid name "#{args[:name]}")
      end
      [serializer]
    else
      Rtypes.all_serializers
    end

    serializers.each do |serializer|
      Rtypes.generate(serializer).each do |file|
        puts file.path
      end
    end

  end

end
