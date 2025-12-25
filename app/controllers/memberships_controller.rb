class MembershipsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_team
  before_action :ensure_leader, only: [:create, :destroy] # 招待と削除はリーダーのみ
  
  
  def create
    # 入力されたメールアドレスでユーザーを検索
    user = User.find_by(email: params[:email])

    if user
      # すでに所属していないかチェックして保存
      @membership = @team.memberships.build(user: user, role: :member)
      if @membership.save
        redirect_to team_path(@team), notice: "#{user.name}さんを招待しました。"
      else
        redirect_to team_path(@team), alert: "そのユーザーは既に追加されています。"
      end
    else
      redirect_to team_path(@team), alert: "ユーザーが見つかりませんでした。"
    end
  end

  def destroy
    # 今のチームに属しているメンバーシップの中から探す
    @membership = @team.memberships.find(params[:id])
    # 1. 権限チェック
    if current_user.leader_of?(@team) || @membership.user == current_user
     # 消去されるユーザーを事前に変数に取っておく（destroy後はデータが消えるため）
      is_self_removal = (@membership.user == current_user)
     if @membership.destroy
      if is_self_removal
        # 自分が脱退した場合：チーム一覧へ
        redirect_to teams_path, notice: "チームを脱退しました。", status: :see_other
      else
        # リーダーが他のメンバーを削除した場合：そのままチーム詳細画面へ
        redirect_to team_path(@team), notice: "メンバーを解除しました。", status: :see_other
      end
     else
      redirect_to team_path(@team), alert: @membership.errors.full_messages.to_sentence, status: :unprocessable_entity
     end
    else
     redirect_to team_path(@team), alert: "権限がありません。"
    end
  end

  private

  def set_team
    @team = Team.find(params[:team_id])
  end

  # リーダー権限チェック
  def ensure_leader
    # 削除アクションかつ自分自身の脱退であれば、リーダーでなくてもスルーさせる
    return if action_name == 'destroy' && @team.memberships.find(params[:id]).user == current_user
    
    unless current_user.leader_of?(@team)
      redirect_to team_path(@team), alert: "リーダー権限が必要です。"
    end
  end

  
end
