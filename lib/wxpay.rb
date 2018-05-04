WxPay.mch_id = ENV['WX_OPEN_MCH_ID']
WxPay.appid = ENV['WX_OPEN_APP_ID']
WxPay.key = ENV['WX_OPEN_API_KEY']
WxPay.extra_rest_client_options = {timeout: 12, open_timeout: 13}
WxPay.sandbox_mode = true unless ENV['SERVER_ENV'] == 'production'
