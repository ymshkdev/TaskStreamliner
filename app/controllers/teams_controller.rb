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
  end
  
  private

  def team_params
    params.require(:team).permit(:name)
  end
end
