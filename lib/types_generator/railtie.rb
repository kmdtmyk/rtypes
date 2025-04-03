class TypesGenerator
  class Railtie < ::Rails::Railtie

    rake_tasks do
      load 'tasks/types_generator_tasks.rake'
    end

  end
end
