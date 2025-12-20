class ApplicationController < ActionController::Base
  # Deviseのコントローラーが動くときに、パラメーター許可のメソッドを呼ぶ
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :basic_auth

  private

  def configure_permitted_parameters
    # 新規登録(sign_up)の際に、nameカラムを許可する
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    # アカウント編集(account_update)の際も許可
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      username == 'admin' && password == '2222'
      #username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]
    end
  end
end
