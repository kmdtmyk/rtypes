namespace :rtypes do

  desc 'Add configuration file'
  task :install do
    FileUtils.cp(
      File.expand_path('../templates/rtypes.rb', __FILE__),
      Rails.root.join('config/initializers'),
      verbose: true
    )
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
