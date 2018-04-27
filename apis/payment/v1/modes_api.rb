module V1
  module Payment
    class ModesAPI < Grape::API
      namespace :payment do
        resources :modes do
          desc '可用支付方式'
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单 UUID'
          end
          get do
            authenticate_user
            begin
              order = @session_user.orders.find_uuid(params[:order_uuid])
              item = order.order_items.first
              {
                settlement:{
                  title: item.product_name,
                  style_name: item.style_name,
                  image: (item.picture.image.style_url('160w') rescue nil),
                  price: "¥ " + item.style.price.to_s,
                  quantity_str: "x#{item.quantity}",
                  total_fee: @session_user.is_developer? ? "￥ 0.1"  : ("￥ " + (item.style.price * item.quantity).to_s),
                  scheme: "lvsent://gogo.cn/mall/products?style_uuid=#{item.style.uuid}"
                },
                modes:[
                  {mode: 'wechat_pay', scheme: "lvsent://gogo.cn/payment/modes/wechat?order_uuid=#{params[:order_uuid]}"},
                  {mode: 'alipay', scheme: "lvsent://gogo.cn/payment/modes/alipay?order_uuid=#{params[:order_uuid]}"},
                  {mode: 'union_pay', scheme: "lvsent://gogo.cn/payment/modes/union?order_uuid=#{params[:order_uuid]}"}
                ]
              }      
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end
          
          desc "微信支付"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单 UUID'
            requires :trade_type, type: String , default: 'APP', values: ['APP', 'JSAPI'], desc: '交易类型'
          end
          post 'wechat_pay' do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid])
              pay_method = params[:trade_type] == 'APP' ? ::Payment::PAY_METHOD_WECHAT : ::Payment::PAY_METHOD_WECHAT_MP
              payment = ::Payment.find_or_create_by_order(order, pay_method)
              pay_params = {
                # body:             '商品：我要卖机油'[0..63],
                body: payment.trade_no,
                out_trade_no:     payment.trade_no,
                total_fee:        (payment.total_fee*100).to_i.to_s,
                spbill_create_ip: request.ip,
                notify_url:       ENV['WX_OPEN_PAY_NOTIFY_URL'],
                trade_type:       params[:trade_type],
                nonce_str:        SecureRandom.uuid.tr('-', ''),
                time_expire:      order.expired_at.localtime.strftime("%Y%m%d%H%M%S")
              }
              pay_params[:openid] = @session_user.wx_open_id if params[:trade_type] == 'JSAPI'
              trade_type_params = case params[:trade_type]
              when 'APP' then {appid: ENV['WX_OPEN_APP_ID'], mch_id: ENV['WX_OPEN_MCH_ID'], key: ENV['WX_OPEN_API_KEY']}
              when "JSAPI" then {appid: ENV['WX_MP_APP_ID'], mch_id: ENV['WX_MP_MCH_ID'], key: ENV['WX_MP_API_KEY']}  
              end  
              ret = WxPay::Service.invoke_unifiedorder pay_params, trade_type_params
              app_error("支付请求创建失败", "wxpay ret was not success") unless ret.success?
              app_params = {prepayid: ret["prepay_id"], noncestr: pay_params[:nonce_str]}
              r = case params[:trade_type]
              when 'APP' then WxPay::Service::generate_app_pay_req(app_params, trade_type_params)
              when 'JSAPI' then WxPay::Service::generate_js_pay_req(app_params, trade_type_params)
              end
              package = r.delete(:package)
              r[:package_value] = package
              r[:result_scheme] = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/mall/orders/payment_result?uuid=#{params[:order_uuid]}")
              r
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "微信支付异步回调通知"
          params do 
            
          end
          post :wechat_pay_notify do
            begin
              result = Hash.from_xml(request.body.read)["xml"]
              if WxPay::Sign.verify?(result)
                payment=::Payment.find_by(trade_no: result['out_trade_no'])
                payment.item.refrensh_status
                status 200
                "<xml><return_code>SUCCESS</return_code></xml>"
              else
                "<xml><return_code>FAIL</return_code><return_msg>签名失败</return_msg></xml>"
              end
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "支付宝支付"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单 UUID'
          end
          post :alipay do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid])
              payment = ::Payment.find_or_create_by_order(order, ::Payment::PAY_METHOD_ALIPAY)
              res = Alipay::INIT_CLIENT.sdk_execute(
              method: 'alipay.trade.app.pay',
              biz_content: {
                out_trade_no: payment.trade_no,
                product_code: 'QUICK_MSECURITY_PAY',
                total_amount: payment.total_fee.to_s,
                subject: '全民拼'  #名称
              }.to_json(ascii_only: true), 
              timestamp: Time.now.localtime.strftime("%Y-%m-%d %H:%M:%S"),
              notify_url: Alipay::NOTIFY_URL,
              timeout_express: order.timeout_express_for_alipay)
              {res: res, result_scheme: "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/mall/orders/payment_result?uuid=#{params[:order_uuid]}")}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end
          desc "支付宝回调"
          params do

          end
          post :alipay_notify do
            begin
              notify_params = params
              if Alipay::INIT_CLIENT.verify?(notify_params) && notify_params['trade_status'] == 'TRADE_SUCCESS'
                payment=::Payment.find_by(trade_no: notify_params['out_trade_no'])
                payment.item.refrensh_status
                status 200
                "success"
              else
                "error"
              end
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
    end
  end
end
