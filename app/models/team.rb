class Team < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships # チームに所属するユーザー一覧を取得可能にする

  validates :name, presence: true, uniqueness: true
end
