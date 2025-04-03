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
    types_generator = TypesGenerator.new(args[:name])
    types_generator.generate
    puts types_generator.file_path
  end

end
