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

    rtypes = if args[:name].present?
      [Rtypes.new(args[:name])]
    else
      Rtypes.all_serializers.map{ Rtypes.new(_1) }
    end

    rtypes.each do |rtypes|
      rtypes.generate
      puts rtypes.file_path
    end

  end

end
