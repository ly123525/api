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
    app_error(nil, "Failed to find the user", 401) if params[:user_uuid].blank? or params[:token].blank?
    user_and_token = ::Account::User.authenticate(params[:user_uuid], params[:token])
    app_error("授权失效，请重新登录!", "Failed to find the user", 401) if user_and_token.blank?
    @session_user = user_and_token[0]
  end
  def client_info_record request, token
    logger.info "================#{request.headers['User-Agent']}"
    logger.info "================#{request.headers['System']}"
    logger.info "================#{request.headers['Device']}"
    logger.info "================#{request.headers['DeviceID']}"
    return unless inner_app?(request)
    token.update(os: os(request), os_version: os_version(request), app_version: app_version(request), app_version_code: app_version_code(request), device: device(request), device_id: device_id(request)) rescue nil
  end
  def inner_app? request
    request.headers['User-Agent'].include?("gogo.cn")
  end
  def os request
    return unless inner_app?(request)
    request.headers['System'].split(' ')[0] rescue nil
  end
  def os_version request
    return unless inner_app?(request)
    request.headers['System'].split(' ')[1] rescue nil
  end
  def device request
    return unless inner_app?(request)
    request.headers['Device']
  end
  def device_id request
    return unless inner_app?(request)
    request.headers['DeviceID']
  end
  def app_version request
    return unless inner_app?(request)
    request.headers['User-Agent'].split('/')[1] rescue nil
  end  
  
  def app_version_code request
    return unless inner_app?(request)
    request.headers['User-Agent'].split('/')[2].to_i rescue nil
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