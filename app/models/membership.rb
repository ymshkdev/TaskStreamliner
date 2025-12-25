class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :team
  # 削除（destroy）される直前に実行
  before_destroy :ensure_at_least_one_leader

  # roleを 0: member, 1: leader として扱う
  enum :role, { member: 0, leader: 1 }
  # user_id と team_id のペアが重複しない（二重所属禁止）ためのバリデーション
  validates :user_id, uniqueness: { scope: :team_id }

private
  def ensure_at_least_one_leader
    # チームそのものが削除（destroyed）されようとしているときは、チェックをスキップする
    return if team.destroyed? || team.marked_for_destruction?
    # 削除しようとしている人がリーダーでないなら、チェック不要
    return unless leader?

    # このチームに自分以外のリーダーが何人いるか数える
    other_leaders_count = team.memberships.where(role: :leader).where.not(id: id).count

    if other_leaders_count == 0
      # リーダーが0人になる場合は削除を中止させる
      errors.add(:base, "リーダーが不在になるため、脱退・削除できません。")
      throw :abort
    end
  end
end
