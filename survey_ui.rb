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

def designer_menu
  puts "Press 'a' to add a new survey."
  puts "Press 'l' to list surveys."
  puts "Press 's' to show a survey, its questions and responses."
  puts "Press 'q' to add questions to an existing survey."
  puts "Press 'r' to add responses to a question."
  puts "Press '%' to see the response rates to a particular question."
  puts "Press 'x' to return to the main menu."
  choice = get_input('Enter your choice:').downcase

  case choice
  when 'a'
    add_survey
    designer_menu
  when 'l'
    list_surveys
    designer_menu
  when 's'
    survey = select_survey
    show(survey)
    designer_menu
  when 'q'
    survey = select_survey
    add_questions(survey)
    designer_menu
  when '%'
    survey = select_survey
    question = select_question(survey)
    view_percents(question)
  when 'r'
    survey = select_survey
    question = select_question(survey)
    add_responses(question)
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

def add_questions(survey)
  add_another = 'y'
  until add_another == 'n'
    prompt = get_input("Please input your question:")
    created_question = survey.questions.create({ :prompt => prompt })
    puts "Your question '#{created_question.prompt}' was created."
    add_responses(created_question)
    add_another = get_input("Do you want to add another question to this survey? (y/n)").downcase
  end
  list_questions(survey)
end

def list_questions(survey)
  puts "--#{survey.name} "
  puts "---Here are your questions:"
  survey.questions.each_with_index do |question, index|
    puts "#{index + 1}. #{question.prompt}"
  end
  puts "-"*20 + "\n"
end

def view_percents(question)
  total_responses = 0
  question.responses.each do |response|
    total_responses += response.times_marked.to_i
  end
  puts "--#{question.prompt}"
  puts "---Here are the response percentages:\n"
  puts "\tpercent | count | response    "
  question.responses.reorder('choice').each do |response|
    puts "\t#{(response.times_marked.to_i/total_responses.to_f)*100} %\t    #{response.times_marked.to_i}  \t  #{response.description}"
  end
end

def add_responses(question)
  letters = ('A'..'F').to_a
  add_another = 'y'
  until add_another == 'n'
    description = get_input("Please input a response to '#{question.prompt}':")
    choice = letters.shift
    new_response = question.responses.create({ :choice => choice, :description => description, :times_marked => 0 })
    puts "#{new_response.choice}. #{new_response.description} has been added."
    if choice == 'F'
      puts "If you would like to enter more responses please contact your system administrator."
      add_another = 'n'
    else
      add_another = get_input("Do you want to add another response? (y/n)").downcase
    end
  end
end

def show(survey)
  system "clear"
  puts "** #{survey.name}"
  puts "=========================\n\n"
  survey.questions.each_with_index do |question, index|
    puts "#{index + 1}. #{question.prompt}"
    question.responses.each do |response|
      puts "\t#{response.choice}) #{response.description}"
    end
    puts "\n\n"
  end
end

#******************************************

def taker_menu
  puts "Press 'f' to find a survey to take."
  puts "Press 'x' to return to the main menu."
  choice = get_input('Enter your choice:').downcase
  case choice
  when 'f'
    survey = select_survey
    take_survey(survey)
  when 'x'
    puts "Returning to main menu."
  else
    puts "Invalid input."
  end
end

def take_survey(survey)
  survey.questions.each_with_index do |question, index|
    system "clear"
    puts "#{survey.name}: Question #{index + 1} of #{survey.questions.length}"
    puts "#{index + 1}. #{question.prompt}"
    question.responses.each do |response|
      puts "\t#{response.choice}) #{response.description}"
    end
    puts "\n\n"
    puts "Enter your answer below, enter 'skip' to skip this question."
    taker_choice = get_input('Your answer: ').upcase
    if taker_choice != 'SKIP'
      chosen_response = nil
      chosen_response = question.responses.select { |response| response.choice == taker_choice }
      chosen_response = chosen_response[0]
      if chosen_response.nil?
        puts "Invalid choice."
      else
        chosen_response.increment!(:times_marked, 1)
        puts "Your answer is #{chosen_response.choice}"
      end
    end
    puts "Press any key for the next question"
    gets.chomp
  end
  puts "Thank you for your responses."
end

#*******************************************

def get_input(question)
  puts question
  gets.chomp
end

def list_surveys
  puts "--Surveys" + "-"*11
  Survey.all.each do |survey|
    puts survey.name
  end
  puts '-'*20 + "\n"
end

def select_survey
  list_surveys
  selected_survey = get_input("What survey would you like to select?")
  survey = Survey.find_by_name(selected_survey)
end

def select_question(survey)
  list_questions(survey)
  question_index = get_input("Enter question number:").to_i - 1
  selected_question = survey.questions[question_index]
end

system "clear"
puts 'Welcome to the Survey Center'
main_menu
