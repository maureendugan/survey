class AddTimesMarkedColumn < ActiveRecord::Migration
  def change
    add_column :responses, :times_marked, :int
  end
end
