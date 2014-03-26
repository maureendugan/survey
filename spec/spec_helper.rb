require 'active_record'
require 'rspec'
require 'shoulda-matchers'

require 'surveys'
require 'questions'
require 'responses'

database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['test']
ActiveRecord::Base.establish_connection(development_configuration)
