module WeixinAuthorize
  module Token
    class Store
      def self.init_with(client)
          RedisStore.new(client)
      end
    end  
  end    
end      
namespace = "weixin:authorize"
redis = Redis.new(url: ENV['REDIS'])
redis = Redis::Namespace.new(namespace, redis: redis)
WeixinAuthorize.configure do |config|
  # config.redis = Redis.new(url: ENV['REDIS'], namespace: namespace)
  config.redis = redis
end
$wx_open_auth = WeixinAuthorize::Client.new(ENV["WX_OPEN_APP_ID"], ENV["WX_OPEN_APP_SECRET"])
$wx_mp_auth = WeixinAuthorize::Client.new(ENV["WX_MP_APP_ID"], ENV["WX_MP_APP_SECRET"] )