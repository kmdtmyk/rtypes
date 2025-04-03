namespace :types_generator do

  desc 'Add configuration file'
  task :install do
    FileUtils.cp(
      File.expand_path('../templates/types_generator.rb', __FILE__),
      Rails.root.join('config/initializers'),
      verbose: true
    )
  end

end
