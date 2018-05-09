WxPay.extra_rest_client_options = {timeout: 12, open_timeout: 13}
module WxPay
  TRADE_APP = "APP"
  TRADE_JSAPI = "JS"
  
  def self.config trade_type
    return {appid: ENV['WX_OPEN_APP_ID'], mch_id: ENV['WX_OPEN_MCH_ID'], key: ENV['WX_OPEN_API_KEY']} if trade_type==::WxPay::TRADE_APP
    {appid: ENV['WX_MP_APP_ID'], mch_id: ENV['WX_MP_MCH_ID'], key: ENV['WX_MP_API_KEY']}  
  end
  module Service
    ORDER_QUERY_REQUIRED_FIELDS = [:out_trade_no]
    def self.order_query(params, options = {})
      params = {
        appid: options.delete(:appid) || WxPay.appid,
        mch_id: options.delete(:mch_id) || WxPay.mch_id,
        key: options.delete(:key) || WxPay.key,
        nonce_str: SecureRandom.uuid.tr('-', '')
      }.merge(params)


      r = WxPay::Result.new(Hash.from_xml(invoke_remote("/pay/orderquery", make_payload(params), options)))
      check_required_options(params, ORDER_QUERY_REQUIRED_FIELDS)

      yield r if block_given?

      r
    end
  end
end