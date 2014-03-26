class CreateQuestionsAndResponses < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.column :prompt, :varchar
      t.column :survey_id, :int

      t.timestamps
    end
    create_table :responses do |t|
      t.column :choice, "char(1)"
      t.column :description, :varchar
      t.column :question_id, :int

      t.timestamps
    end
  end
end
