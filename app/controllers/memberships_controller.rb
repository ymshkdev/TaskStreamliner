class MembershipsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @team = Team.find(params[:team_id])
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
    membership = Membership.find(params[:id])
    team = membership.team
    membership.destroy
    redirect_to team_path(team), notice: "メンバーを解除しました。"
  end
end
