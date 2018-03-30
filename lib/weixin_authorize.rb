namespace = "weixin:authorize"
WeixinAuthorize.configure do |config|
  config.redis = Redis.new(url: ENV['REDIS'], namespace: namespace)
end
$wx_open_auth = WeixinAuthorize::Client.new(ENV["WX_OPEN_APP_ID"], ENV["WX_OPEN_APP_SECRET"])
$wx_mp_auth = WeixinAuthorize::Client.new(ENV["WX_MP_APP_ID"], ENV["WX_MP_APP_SECRET"] )