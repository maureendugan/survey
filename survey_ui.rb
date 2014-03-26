require 'active_record'

require './lib/surveys'
require './lib/questions'
require './lib/responses'


database_configurations = YAML::load(File.open('./db/config.yml'))
development_configuration = database_configurations['development']
ActiveRecord::Base.establish_connection(development_configuration)

I18n.enforce_available_locales = false


def main_menu

  choice = nil
  until choice == 'exit'
    puts "Enter any key to find a survey to take."
    puts "Enter 'login' to enter the designer portal."
    puts "Enter 'exit' to leave the survey portal."
    choice = get_input('Enter your choice:').downcase
    case choice
    when 'login'
      designer_menu
    when 'exit'
      puts "Thank you for your visit."
    else
      taker_menu
    end
  end
end

def get_input(question)
  puts question
  gets.chomp
end

def designer_menu
  puts "Press 'a' to add a new survey."
  puts "Press 'l' to list surveys."
  puts "Press 'x' to return to the main menu."
  choice = get_input('Enter your choice:').downcase

  case choice
  when 'a'
    add_survey
    designer_menu
  when 'l'
    list_surveys
    designer_menu
  when 'x'
    puts 'Returning to main menu.'
  else
    puts "That is not a valid input."
    designer_menu
  end
end

def add_survey
  user_input = get_input("What is the name of your survey?")
  new_survey = Survey.new({ :name => user_input })
  if new_survey.save
    puts "Created #{new_survey.name}"
  else
    puts "That survey already exists. Try creating your new survey with a different name."
  end
end

def list_surveys
  puts "--Surveys" + "-"*11
  Survey.all.each do |survey|
    puts survey.name
  end
  puts '-'*20 + "\n"
end

#******************************************

def taker_menu
end


system "clear"
puts 'Welcome to the Survey Center'
main_menu
