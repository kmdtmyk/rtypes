class Rtypes
  class Railtie < ::Rails::Railtie

    rake_tasks do
      load 'tasks/rtypes_tasks.rake'
    end

  end
end
