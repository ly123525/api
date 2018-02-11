module APIHelpers
  def logger
    Grape::API.logger
  end
  
  def app_error tips, error, code=400
    error!({code: code, tips: tips, error: error}, 200)
  end

  def app_uuid_error
    app_error("无效参数，请检查后重试", "Invalid UUID")
  end

  def server_error ex=nil
    puts ex.try(:backtrace) rescue nil
    app_error("系统错误", "Server error", 500)
  end
  
  # 用户授权
  def authenticate_user
    logger.info "================#{request.headers['User-Agent']}"
    logger.info "================#{request.headers['System']}"
    logger.info "================#{request.headers['Device']}"
    app_error(nil, "Failed to find the user", 401) if params[:user_uuid].blank? or params[:token].blank?
    @session_user = ::Account::User.authenticate(params[:user_uuid], params[:token])
    app_error("授权失效，请重新登录!", "Failed to find the user", 401) if @session_user.blank?
  end
  
  # 手机号码格式验证
  def valid_phone?
    return if params[:phone].blank?
    (params[:phone] =~ /^1\d{10}$/).present?
  end
  
  # 验证码格式验证
  def valid_captcha?
    return if params[:captcha].blank?
    (params[:captcha] =~ /^\d{4}$/).present?
  end
end

