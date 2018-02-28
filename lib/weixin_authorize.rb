namespace = "weixin:authorize"
WeixinAuthorize.configure do |config|
  config.redis = Redis.new(url: ENV['REDIS'], namespace: namespace)
end
$wx_mp_auth = WeixinAuthorize::Client.new(ENV["WX_MP_APP_ID"], ENV["WX_MP_APP_SECRET"])