class TeamsController < ApplicationController
  before_action :authenticate_user!

  def index
    @teams = current_user.teams
  end

  def new
    @team = Team.new
  end

  def create
    @team = Team.new(team_params)
    
    # チーム作成とリーダー登録を同時に行う
    ActiveRecord::Base.transaction do
      if @team.save
        @team.memberships.create!(user: current_user, role: :leader)
        redirect_to teams_path, notice: "チーム「#{@team.name}」を作成しました！"
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    @team = Team.find(params[:id])
    @members = @team.users.order('memberships.role DESC')
    # ユーザーと一緒に、そのチームでの membership もまとめて取得(N+1対策)
    @memberships = @team.memberships.includes(:user).order(role: :desc)
  end

  def destroy
   @team = Team.find(params[:id])  
   # リーダーだけがチームを削除（解散）できる
   if current_user.leader_of?(@team)
    @team.destroy
    redirect_to teams_path, notice: "チーム「#{@team.name}」を削除しました。"
   else
    redirect_to team_path(@team), alert: "リーダー以外はチームを削除できません。"
   end
  end

  private

  def team_params
    params.require(:team).permit(:name)
  end
end
