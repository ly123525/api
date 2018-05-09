WxPay.extra_rest_client_options = {timeout: 12, open_timeout: 13}
module WxPay
  TRADE_APP = "APP"
  TRADE_JSAPI = "JSAPI"
  
  def self.config trade_type
    return {appid: ENV['WX_OPEN_APP_ID'], mch_id: ENV['WX_OPEN_MCH_ID'], key: ENV['WX_OPEN_API_KEY']} if trade_type==::WxPay::TRADE_APP
    {appid: ENV['WX_MP_APP_ID'], mch_id: ENV['WX_MP_MCH_ID'], key: ENV['WX_MP_API_KEY']}  
  end
end