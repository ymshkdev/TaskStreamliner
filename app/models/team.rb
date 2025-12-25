class Team < ApplicationRecord
  has_many :memberships, dependent: :delete_all
  has_many :users, through: :memberships # チームに所属するユーザー一覧を取得可能にする
  # 【追加】チームを消すときは、タスクの共有情報も一緒に消す
  # モデル名（task_shares）は、このプロジェクトの定義に合わせる
  has_many :task_shares, dependent: :delete_all

  validates :name, presence: true, uniqueness: true
end
