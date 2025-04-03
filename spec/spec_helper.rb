# frozen_string_literal: true

require "types_generator"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


require "active_record"
require "active_model_serializers"

Dir.glob(File.expand_path('../models/*.rb', __FILE__)) do |file|
  require file
end

Dir.glob(File.expand_path('../serializers/*.rb', __FILE__)) do |file|
  require file
end

require 'fileutils'

FileUtils.rm('tmp/database.sqlite3', force: true)

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'tmp/database.sqlite3',
)

ActiveRecord::Base.connection.create_table :users do |t|
  t.string :name
end

ActiveRecord::Base.connection.create_table :posts do |t|
  t.string :datetime
  t.string :title
  t.string :body
  t.references :user
end
