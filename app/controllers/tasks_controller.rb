class TasksController < ApplicationController
 before_action :authenticate_user! # ログイン必須にする
  def index
    # current_user.tasks と書くことで、タスクが0件でも nil ではなく
    # 「空のデータセット」が返るため、カレンダーが表示されるようにする
    @tasks = current_user.tasks
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
  if @task.save
    # 保存に成功したら、カレンダー画面（index）へリダイレクト
    redirect_to tasks_path, notice: "予定を帳面に書き込みました"
  else
    # 失敗した場合は入力画面を再表示
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
  params.require(:task).permit(:title, :description, :deadline, :priority, :status)
end

end
