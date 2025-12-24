class CreateTaskShares < ActiveRecord::Migration[7.1]
  def change
    create_table :task_shares do |t|
      t.references :task, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true

      t.timestamps
    end
    # 同じタスクを同じチームに二重に共有できないようにする（インデックス）
    add_index :task_shares, [:task_id, :team_id], unique: true
  end
end
