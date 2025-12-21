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

  # task_type の定義 (0: タスク, 1: 予定)
  enum task_type: { todo: 0, schedule: 1 }

  validates :title, presence: true, length: { maximum: 50 }
  validates :priority, presence: true
  
  # 予定（schedule）の場合のみ、開始時間と終了時間を必須にするバリデーション
  validates :start_at, presence: true, if: :schedule?
  validates :end_at, presence: true, if: :schedule?

  # 終了時間が開始時間より後であることを確認するカスタムバリデーション
  validate :end_at_after_start_at

  # カレンダー表示に使う日付を動的に切り替えるメソッド
  def start_time
    if todo?
      deadline    # タスクなら締切日を返す
    else
      start_at    # 予定なら開始時間を返す
    end
  end

  private

  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?
    if end_at < start_at
      errors.add(:end_at, "は開始時間より後の時間に設定してください")
    end
  end
end
