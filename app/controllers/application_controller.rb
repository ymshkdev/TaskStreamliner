class ApplicationController < ActionController::Base
  # Deviseのコントローラーが動くときに、パラメーター許可のメソッドを呼ぶ
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    # 新規登録(sign_up)の際に、nameカラムを許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # アカウント編集(account_update)の際も許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end
