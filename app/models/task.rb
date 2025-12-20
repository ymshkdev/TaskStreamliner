class Task < ApplicationRecord
  belongs_to :user

  # priorityカラムの 0, 1, 2 を定義
  enum priority: { low: 0, middle: 1, high: 2 }, _prefix: true
end
