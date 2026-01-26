namespace :rtypes do

  desc 'Add configuration file'
  task :install do
    file = File.open(Rails.root.join('config/initializers/rtypes.rb'), 'w') do |f|
      f.puts Rtypes.config_file_content
      f
    end
    puts file.path
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
      file = Rtypes.new(serializer).generate
      if file != nil
        puts file.path
      end
    end

  end

end
