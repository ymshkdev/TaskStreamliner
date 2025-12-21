class AddScheduleColumnsToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :task_type, :integer, default: 0
    add_column :tasks, :start_at, :datetime
    add_column :tasks, :end_at, :datetime
  end
end
