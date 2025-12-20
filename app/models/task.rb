class Task < ApplicationRecord
  belongs_to :user
  # タイトルを必須（空欄禁止）にし、最大50文字の制限
  validates :title, presence: true, length: { maximum: 50 }
  # メモ（description）は必須ではないので、記載しない
  # 優先度やステータスも必須にしたい場合は追加する
  validates :priority, presence: true
  # statusを実装するまでは、以下のバリデーションはコメントアウト
  #validates :status, presence: true
  # priorityカラムの 0, 1, 2 を定義
  enum priority: { low: 0, middle: 1, high: 2 }, _prefix: true
  #statusの実装で使用
  #enum status: { todo: 0, doing: 1, done: 2 }
end
