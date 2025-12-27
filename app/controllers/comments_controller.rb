class CommentsController < ApplicationController
  def create
    @task = Task.find(params[:task_id])
    @comment = @task.comments.build(comment_params)
    @comment.user = current_user # ログインユーザーを紐付け

    respond_to do |format|
     if @comment.save
      format.turbo_stream
      format.html {redirect_to task_path(@task), notice: "コメントを投稿しました"}
     else
      format.html {redirect_to task_path(@task), alert: "コメントの投稿に失敗しました"}
     end
    end
  end

  def destroy
  @task = Task.find(params[:task_id])
  @comment = @task.comments.find(params[:id])

  # 権限チェック：コメントの作成者本人、またはチームのリーダーであれば削除可能
  if @comment.user == current_user || @task.teams.any? { |team| current_user.leader_of?(team) }
     @comment.destroy
    respond_to do |format|
     format.turbo_stream
     format.html {redirect_to task_path(@task), notice: "コメントを削除しました。", status: :see_other}
    end
  else
    redirect_to task_path(@task), alert: "権限がありません。"
  end
end

  private

  def comment_params
    params.require(:comment).permit(:content)
  end
end
