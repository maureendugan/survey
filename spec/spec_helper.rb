require 'active_record'
require 'rspec'
require 'shoulda-matchers'

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['test']
ActiveRecord::Base.establish_connection(development_configuration)
