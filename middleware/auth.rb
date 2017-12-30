module API
  class Auth < Grape::Middleware::Base

    def before
      return if env['PATH_INFO'].include?('/doc/swagger_doc')
      params = env['QUERY_STRING'].split("&").map{|param| param.split("=")}.to_h
      params['signature'] = env['HTTP_SIGNATURE']
      params['timestamp'] = env['HTTP_TIMESTAMP']
      env['api.endpoint'].error!({error: "internal error!"},401) unless verify?(params)
    end

    private
    # 签名算法
    # 请求来源(身份)是否合法？
    # 防篡改？
    # 唯一性(不可复制)
    # params:   param1=value1&param2=value2….&timestamp=20171226100000
    # sign:     md5(secret+params)
    # 所有参数按字母顺序排序
    def generate(params)
      query = params.sort.map do |k, v|
        "#{k}=#{v}" if v.to_s.present?
      end.compact.join('&')
      Digest::MD5.hexdigest(ENV['API_SECRET'] + query).upcase
    end

    def verify?(params)
      sign = params.delete('signature')
      generate(params) == sign
    end

  end
end
