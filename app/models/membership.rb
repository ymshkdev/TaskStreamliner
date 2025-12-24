class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team

  # roleを 0: member, 1: leader として扱う
  enum :role, { member: 0, leader: 1 }
  # user_id と team_id のペアが重複しない（二重所属禁止）ためのバリデーション
  validates :user_id, uniqueness: { scope: :team_id }
end
