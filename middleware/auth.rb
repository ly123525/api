module API
  class Auth < Grape::Middleware::Base

    def before
      return if env['PATH_INFO'].include?('/doc/swagger_doc')
      return if env['PATH_INFO'].include?('v1/wx_token_verfity.txt')
      return if ENV['SERVER_ENV']=='development'
      request = Grape::Request.new(@env, build_params_with: @options[:build_params_with])
      params = request.params
      Grape::API.logger.info "===================#{params.to_s}"
      Grape::API.logger.info "===================#{env['HTTP_SIGNATURE']}"
      Grape::API.logger.info "===================#{env['HTTP_TIMESTAMP']}"
      Grape::API.logger.info "===================#{env['HTTP_NONCE']}"
      params['signature'] = env['HTTP_SIGNATURE']
      params['timestamp'] = env['HTTP_TIMESTAMP']
      params['nonce'] = env['HTTP_NONCE']
      sign = params['signature']
      env['api.endpoint'].error!({error: "internal error!"},401) unless verify?(params)
      base_auth_record=$redis.write(sign, params['nonce'], Time.now + 12.hour)
    end

    # 签名算法
    # 请求来源(身份)是否合法？
    # 防篡改？
    # 唯一性(不可复制)
    # params:   param1=value1&param2=value2….&timestamp=20171226100000
    # sign:     md5(secret+params)
    # 所有参数按字母顺序排序
    def generate(params)
      query = params.sort.map do |k, v|
        "#{k}=#{v}" if v.to_s != ''
      end.compact.join('&')
      Digest::MD5.hexdigest(ENV['API_SECRET'] + query).upcase
    end

    def verify?(params)
      return false unless (Time.now-12.hour..Time.now+12.hour).include?( Time.at(params['timestamp'].to_i) )
      return false if $redis.exists?(params['signature']) && $redis.read(params['signature']) == params['nonce']      
      sign = params.delete('signature')
      generate(params) == sign
    end

  end
end
