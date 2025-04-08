namespace :types_generator do

  desc 'Add configuration file'
  task :install do
    FileUtils.cp(
      File.expand_path('../templates/types_generator.rb', __FILE__),
      Rails.root.join('config/initializers'),
      verbose: true
    )
  end

  desc 'Generate typescript definition file'
  task :generate, [:name] => :environment do |task, args|

    types_generators = if args[:name].present?
      [TypesGenerator.new(args[:name])]
    else
      models = ActiveRecord::Base.connection.tables.map{ _1.classify.safe_constantize }.compact
      models
        .filter{ "#{_1.name}Serializer".safe_constantize.present? }
        .map{ TypesGenerator.new(_1.name) }
    end

    types_generators.each do |types_generator|
      types_generator.generate
      puts types_generator.file_path
    end

  end

end
