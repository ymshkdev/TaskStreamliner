class Task < ApplicationRecord
  belongs_to :user

  # --- 共通のバリデーション ---
  validates :title, presence: true, length: { maximum: 50 }
  validates :priority, presence: true
  validates :status, presence: true, if: :todo?
  
  # --- status ---
  validates :status, presence: true
  enum :status,{ todo: 0, doing: 1, done: 2 }, default: :todo, prefix: true
  def done?
    # 完了済みをdoneと定義
    status_done?
  end
  # --- Enumの定義 ---
  enum :priority, { low: 0, middle: 1, high: 2 }, prefix: true
  enum :task_type, { todo: 0, schedule: 1 }

  # --- タイプ別のバリデーション ---
  
  # 1. タスク(todo)の場合、締切(deadline)を必須にする
  validates :deadline, presence: true, if: :todo?

  # 2. 予定(schedule)の場合、開始と終了を必須にする
  validates :start_at, presence: true, if: :schedule?
  validates :end_at, presence: true, if: :schedule?

  # 時間の前後関係チェック
  validate :end_at_after_start_at

  # --- カレンダー表示用メソッド ---
  def start_time
    todo? ? deadline : start_at
  end

  private

  # 予定の終了時間が開始時間より前にならないようにチェック
  def end_at_after_start_at
    return if end_at.blank? || start_at.blank?
    if end_at < start_at
      errors.add(:end_at, "は開始時間より後の時間に設定してください")
    end
  end
end