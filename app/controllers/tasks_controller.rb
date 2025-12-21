class TasksController < ApplicationController
 before_action :authenticate_user! # ログイン必須にする
  def index
   # 1. 基準となる日付（@start_date）を決定する
   if params[:year] && params[:month]
    # 年月セレクトボックスからジャンプしてきた場合
    @start_date = Date.new(params[:year].to_i, params[:month].to_i, 1)
   elsif params[:start_date]
    # カレンダーの「前月」「次月」ボタンを押した場合
    @start_date = Date.parse(params[:start_date])
   else
    # 何も指定がない場合は今日の日付
    @start_date = Date.today
   end
    # 2. 決定した @start_date を元に、その月のタスクと予定を取得する
    # beginning_of_month（月初）から end_of_month（月末）の範囲を指定
    # current_user.tasks と書くことで、タスクが0件でも nil ではなく
    # 「空のデータセット」が返るため、カレンダーが表示されるようにする
    @tasks = current_user.tasks.where(
     start_at: @start_date.beginning_of_month..@start_date.end_of_month
     ).or(
     current_user.tasks.where(deadline: @start_date.beginning_of_month..@start_date.end_of_month)
     )
  end
  
  def new
  @task = Task.new
  # カレンダーからの deadline パラメータがあればセット、なければ今日の日付
  if params[:deadline]
    @task.deadline = params[:deadline]
  else
    @task.deadline = Time.current
  end
 end

 def create
  @task = current_user.tasks.build(task_params)
  # 保存前に、タイプに合わせて不要な項目をクリアする
  if @task.todo?
    @task.start_at = nil
    @task.end_at = nil
  elsif @task.schedule?
    @task.deadline = nil
  end

  if @task.save
    # 保存に成功したら一覧画面へ
    redirect_to tasks_path, notice: "登録しました"
  else
    # 失敗したら入力画面を再表示
    render :new, status: :unprocessable_entity
  end
end

def show
  @task = current_user.tasks.find(params[:id])
end

 def edit
  # 自分のタスクだけを編集できるように取得
  @task = current_user.tasks.find(params[:id])
 end

 def update
  @task = current_user.tasks.find(params[:id])
  if @task.update(task_params)
    redirect_to tasks_path, notice: "予定を更新しました"
  else
    render :edit, status: :unprocessable_entity
  end
 end

 def destroy
  @task = current_user.tasks.find(params[:id])
  @task.destroy
  # 削除した後はカレンダー画面に戻る
  # status: :see_other は Rails 7 (Turbo) で推奨されているリダイレクトのステータスです
  redirect_to tasks_path, notice: "予定を削除しました", status: :see_other
 end

private

def task_params
  params.require(:task).permit(:title, :description, :deadline, :priority, :status, :task_type, :start_at, :end_at).tap do |p|
    p[:priority] = p[:priority].to_i if p[:priority].present?
  end
end

end
