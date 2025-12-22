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
    # 1. 月の範囲を「時間の端から端まで」定義
    month_start = @start_date.beginning_of_month.beginning_of_day
    month_end   = @start_date.end_of_month.end_of_day

    # 2. カレンダー表示用：修正した範囲（month_start..month_end）を使う
    @tasks = current_user.tasks.where(start_at: month_start..month_end)
                               .or(current_user.tasks.where(deadline: month_start..month_end))
     @todo_list = current_user.tasks
                             .todo               # タイプがタスクのもの
                             .status_todo        # ステータスが「未着手」
                             .or(current_user.tasks.status_doing) # または「進行中」
                             .order(priority: :desc, deadline: :asc)
  end
  
  def new
   # current_user.tasks.build にすることで、最初から user_id がセットされた状態で作成
   @task = current_user.tasks.build
   # カレンダーの「＋」ボタンから selected_date が送られてきた場合
   if params[:selected_date].present?
    # 文字列を日付オブジェクトに変換
    date = Date.parse(params[:selected_date])
    # 1. 予定（schedule）用の初期値（その日の 09:00 〜 10:00 など）
    @task.start_at = date.in_time_zone.change(hour: 9, min: 0)
    @task.end_at   = date.in_time_zone.change(hour: 10, min: 0)
    # 2. タスク（todo）用の初期値（その日の 00:00）
    @task.deadline = date.in_time_zone.beginning_of_day
   else
    # 直接「新規登録」ボタンを押した場合は、現在時刻を基準にする
    @task.deadline = Time.current.end_of_day
    @task.start_at = Time.current.change(hour: 9, min: 0)
    @task.end_at   = Time.current.change(hour: 10, min: 0)
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
    @task.status = :todo # 予定の場合はステータスをデフォルトに戻す
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

 def day
  # 1. 右側に表示する「特定の1日」のデータ
  @date = params[:date] ? Date.parse(params[:date]) : Date.today
  day_range = @date.beginning_of_day..@date.end_of_day
  @day_tasks = current_user.tasks.where(start_at: day_range)
                                 .or(current_user.tasks.where(deadline: day_range))
                                 .order(:start_at, :deadline)

  # 2. 左側の「ミニカレンダー」が「何月」を表示するかを決定
  # URLにstart_dateがあればそれを優先。なければ表示中の日の月初にする。
  @start_date = params[:start_date] ? Date.parse(params[:start_date]) : @date.beginning_of_month
  
  # ミニカレンダーに表示するドット（予定ありマーク）を取得するための範囲
  month_start = @start_date.beginning_of_month.beginning_of_day
  month_end   = @start_date.end_of_month.end_of_day
  
  @month_tasks = current_user.tasks.where(start_at: month_start..month_end)
                                   .or(current_user.tasks.where(deadline: month_start..month_end))

  # 3. 未完了タスク
  @todo_list = current_user.tasks.todo.where(status: [:todo, :doing]).order(priority: :desc, deadline: :asc)
end

private

def task_params
  params.require(:task).permit(:title, :description, :deadline, :priority, :status, :task_type, :start_at, :end_at)
end

end
