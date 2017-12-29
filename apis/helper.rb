module Helpers      
  def app_error tips, error, code=400, location=request.path, error_message=nil
    error!({code: code, tips: tips, error: error, location: location, error_message: error_message}, 200)
  end

  def app_uuid_error location=request.path, error_message=nil
    error!({code: 400, tips: "无效参数, 请检查后重试", error: "Invalid uuid", location: location, error_message: error_message}, 200)
  end

  def server_error ex=nil, location=request.path
    puts ex.try(:backtrace) rescue nil
    error!({code: 500, tips: '系统错误', error: 'server error', location: location, error_message: ex.try(:message)}, 200)
  end

  def validate_user
    begin
      user_token = User.find_user_token(params[:user_uuid], request)
      @session_user = user_token[0]
    rescue ActiveRecord::RecordNotFound
      error!({code: 401, tips: "无效用户，请重新登录!", error: "invalid user uuid", location: "validate_user", error_message: ""}, 200)
    end
  end

  def authenticate_user
    if params[:user_uuid].present? and params[:token].present?
      begin
        user_token = User.find_user_token(params[:user_uuid], request)
        @session_user = user_token[0]
        token = user_token[1]

        error!({code: 401, tips: "授权失效, 请重新登录!", error: "invalid token", location: "authenticate_user", error_message: ""}, 200) if token.present? and token.content != params[:token]
      rescue ActiveRecord::RecordNotFound
        error!({code: 401, tips: "无效用户，请重新登录!", error: "failed to find the user", location: "authenticate_user", error_message: ""}, 200)
      end
    else
      error!({code: 401, tips: "无效用户，请重新登录!", error: "invalid user uuid", location: "authenticate_user", error_message: ""}, 200)
    end
  end

  def authenticate_user_if_signed_in
    if params[:user_uuid].present? and params[:token].present?
      authenticate_user
    end
  end
      
  #强制升级检查
  def forced_upgrade_check!(request, version="2.1.0")
    return if request.blank? or request.headers['App-Version'].blank?
    if ::AppInfoHelper.app_version_less_than?(request, version)
      error!({code: 403, tips: "此功能需要升级到最新版，为了更好的使用请升级...", error: "client version too low", location: "forced_upgrade_check", error_message: ""}, 200)
    end
  end
  
end

