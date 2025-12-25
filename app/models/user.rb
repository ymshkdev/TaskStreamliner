class User < ApplicationRecord
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :memberships, dependent: :destroy
  has_many :teams, through: :memberships # 自分が所属しているチーム一覧を取得可能にする
  has_many :tasks,dependent: :destroy # 自分が作成したタスク一覧
  has_many :comments, dependent: :destroy #自分がコメントした一覧

  def leader_of?(team)
    # membershipsテーブルに「そのチームのリーダーである」というレコードがあるか確認
    memberships.exists?(team: team, role: 'leader')
  end

  validates :name, presence: true
end
