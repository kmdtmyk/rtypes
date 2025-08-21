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
      models = ActiveRecord::Base.connection.tables.map{ _1.classify.safe_constantize }.compact
      models
        .filter{ "#{_1.name}Serializer".safe_constantize.present? }
        .map{ Rtypes.new(_1.name) }
    end

    rtypes.each do |rtypes|
      rtypes.generate
      puts rtypes.file_path
    end

  end

end
