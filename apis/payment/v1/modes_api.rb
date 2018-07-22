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
            optional :order_type, type: String, default: ::Payment::ORDER_TYPE_PRODUCT, values: [::Payment::ORDER_TYPE_PRODUCT, ::Payment::ORDER_TYPE_VIP], desc: '订单类型'
          end
          get do
            authenticate_user
            begin
              {
                settlement: ::Payment.settlement(@session_user, params[:order_uuid], params[:order_type]),
                modes:[
                  {mode: 'wechat_pay', scheme: "lvsent://gogo.cn/payment/modes/wechat?order_uuid=#{params[:order_uuid]}&order_type=#{params[:order_type]}"},
                  {mode: 'alipay', scheme: "lvsent://gogo.cn/payment/modes/alipay?order_uuid=#{params[:order_uuid]}&order_type=#{params[:order_type]}"},
                  {mode: 'union_pay', scheme: "lvsent://gogo.cn/payment/modes/union?order_uuid=#{params[:order_uuid]}&order_type=#{params[:order_type]}"}
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
            requires :trade_type, type: String , default: ::WxPay::TRADE_APP, values: [::WxPay::TRADE_APP, ::WxPay::TRADE_JSAPI], desc: '交易类型'
            optional :order_type, type: String, default: ::Payment::ORDER_TYPE_PRODUCT, values: [::Payment::ORDER_TYPE_PRODUCT, ::Payment::ORDER_TYPE_VIP], desc: '订单类型'
          end
          post 'wechat_pay' do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid]) if params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              fight_group = order.fight_group if params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              order = @session_user.vip_orders.find_uuid(params[:order_uuid]) if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              fight_group = nil if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              payment = ::Payment.create_by_order(order, ::Payment.wx_trade_type_to_pay_method(params[:trade_type]))
              pay_params = {
                body: "全民拼-订单编号#{order.number}",
                out_trade_no:     payment.trade_no,
                total_fee:        (payment.total_fee*100).to_i.to_s,
                spbill_create_ip: request.ip,
                notify_url:       ENV['WX_OPEN_PAY_NOTIFY_URL'],
                trade_type:       params[:trade_type],
                nonce_str:        SecureRandom.uuid.tr('-', ''),
                time_expire:      (Time.now+2.minute).localtime.strftime("%Y%m%d%H%M%S")
              }
              pay_params[:openid] = @session_user.wx_open_id if params[:trade_type] == ::WxPay::TRADE_JSAPI

              ret = WxPay::Service.invoke_unifiedorder pay_params, ::WxPay.config(params[:trade_type])
              app_error("支付请求创建失败", "wxpay ret was not success") unless ret.success?
              app_params = {prepayid: ret["prepay_id"], noncestr: pay_params[:nonce_str]}
              r = WxPay::Service.send("generate_#{params[:trade_type].gsub('API', '').downcase}_pay_req", app_params, ::WxPay.config(params[:trade_type]))
              package = r.delete(:package)
              r[:package_value] = package
              inner_app = inner_app? request
              r[:result_scheme] = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/vip/buy_result?uuid=#{order.uuid}") if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              r[:result_scheme] = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{fight_group.uuid}") if fight_group.present? && inner_app && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              r[:result_scheme] = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/maverick/buying/success?uuid=#{order.uuid}") if !fight_group.present? && inner_app && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              r[:result_scheme] = "#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{fight_group.uuid}" if fight_group.present? && !inner_app && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              r[:result_scheme] = "#{ENV['H5_HOST']}/#/maverick/buying/success?uuid=#{order.uuid}" if !fight_group.present? && !inner_app && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
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
            optional :order_type, type: String, default: ::Payment::ORDER_TYPE_PRODUCT, values: [::Payment::ORDER_TYPE_PRODUCT, ::Payment::ORDER_TYPE_VIP], desc: '订单类型'
          end
          post :alipay do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid]) if params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              fight_group = order.fight_group if params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              order = @session_user.vip_orders.find_uuid(params[:order_uuid]) if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              fight_group = nil if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              payment = ::Payment.create_by_order(order, ::Payment::PAY_METHOD_ALIPAY)
              res = Alipay::INIT_CLIENT.sdk_execute(
              method: 'alipay.trade.app.pay',
              biz_content: {
                out_trade_no: payment.trade_no,
                product_code: 'QUICK_MSECURITY_PAY',
                total_amount: payment.total_fee.to_s,
                subject: '全民拼'
              }.to_json(ascii_only: true),
              timestamp: Time.now.localtime.strftime("%Y-%m-%d %H:%M:%S"),
              notify_url: Alipay::NOTIFY_URL,
              timeout_express: "2m")
              result_scheme = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{fight_group.uuid}") if fight_group.present? && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              result_scheme = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/maverick/buying/success?uuid=#{order.uuid}") if  !fight_group.present? && params[:order_type] == ::Payment::ORDER_TYPE_PRODUCT
              result_scheme = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/vip/buy_result?uuid=#{order.uuid}") if params[:order_type] == ::Payment::ORDER_TYPE_VIP
              {res: res, result_scheme: result_scheme }
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
