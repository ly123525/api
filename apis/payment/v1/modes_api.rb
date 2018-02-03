module A1
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
            [
              {mode: 'wechat_pay', scheme: 'lvsent://gogo.cn/payment?mode=wechat_pay&order_uuid=EGEBE'},
              {mode: 'alipay', scheme: 'lvsent://gogo.cn/payment?mode=alipay&order_uuid=EGEBE'},
              {mode: 'union_pay', scheme: 'lvsent://gogo.cn/payment?mode=union_pay&order_uuid=EGEBE'}
            ]
          end
          
          desc "微信支付"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单 UUID'
            requires :trade_type, type: String , default: 'APP', values: ['APP', 'JSAPI'], desc: '交易类型'
          end
          post 'wechat_pay' do
            authenticate_user
            begin
              pay_params = {
                body:             '商品：我要卖机油'[0..63],
                out_trade_no:     'EE232',
                total_fee:        100,
                spbill_create_ip: request.remote_id,
                notify_url:       ENV['WX_PAY_NOTIFY_URL'],
                trade_type:       params[:trade_type],
                nonce_str:        SecureRandom.uuid.tr('-', ''),
                time_expire:      Time.now+1.hour
              }
              ret = WxPay::Service.invoke_unifiedorder pay_params
              app_error("支付请求创建失败", "wxpay ret was not success") unless ret.success?
    
              app_params = {prepayid: ret["prepay_id"], noncestr: pay_params[:nonce_str]}
              r = case params[:trade_type]
              when 'APP' then WxPay::Service::generate_app_pay_req(app_params)
              when 'JSAPI' then WxPay::Service::generate_js_pay_req(app_params)
              end
              package = r.delete(:package)
              r[:package_value] = package
              r
            rescue ActiveRecord::RecordNotFound
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:对象找不到".red
              app_uuid_error
            rescue Payment::TradeTypeException => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:无效的交易类型".red
              app_error("无效的交易类型", ex.message)
            rescue OrderNoPay => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单不能被支付".red
              app_error("订单不能被支付", ex.message)
            rescue Payment::CategoryUndefinedException => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单类型错误".red
              app_error("订单类型错误", ex.message)
            rescue Payment::AmountMismatchException => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单金额不正确".red
              app_error("订单金额不正确", ex.message)
            rescue Payment::PayMethodUnavailableException => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:支付方式不可用".red
              app_error("支付方式不可用", ex.message)
            rescue Exception => ex
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:系统错误".red
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Message:#{ex.message}".red
              puts "API_V10::PaymentsAPI::property::wechat_pay====>Backgrace:#{ex.backtrace}".red
              server_error(ex)
            ensure
              puts "API_V10::PaymentsAPI::property::wechat_pay==>END--------------------------------------------------------------------------------------------------".green
            end
          end
          
        end
      end
    end
  end
end
      


# module API_V10
#   class PaymentsAPI < Grape::API
#     namespace :property do
#       resources :payments do
#         desc "零钱支付"
#         params do
#           requires :user_uuid, type: String, desc: '用户UUID'
#           requires :token, type: String, desc: '用户访问令牌'
#           requires :category, type: String, desc: "订单类型[#{Payment::AVAILABLE_CATEGORY.keys*"、"}]", default: 'shop_v2_order'
#           requires :uuid, type: String, desc: '订单UUID'
#           optional :hashed_payment_code, type: String, desc: 'md5支付密码'
#         end
#         post 'wallet_pay' do
#           authenticate_user
#           begin
#
#             wallet = ::Account::Wallet.find_or_create_by(user_id: @session_user.id)
#             case wallet.verify(params[:hashed_payment_code])
#             when 'upgrade'
#               app_error("账户已设置支付密码，请升级App", "lack of payment code")
#             when 'locked'
#               app_error("余额账户冻结时间还有#{((wallet.verification_unlock_at - Time.now)/60).round}分钟", 'still locked', 405)
#             when 'locking'
#               app_error("支付密码错误已达5次，请找回密码或者30分钟后重试", 'retry after 30 minutes', 405)
#             when 'retry'
#               app_error("支付密码错误，您还有#{5 - wallet.verification_failed_times.to_i}次尝试机会", 'invalid payment code')
#             end
#
#             wallet.reset_verification
#
#             puts "API_V10::PaymentsAPI::property::wallet_pay==>start--------------------------------------------------------------------------------------------------".green
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>params:#{params}".green
#             raise Payment::CategoryUndefinedException, "category invalid" unless Payment::AVAILABLE_CATEGORY.keys.include?(params[:category])
#             raise Payment::PayMethodUnavailableException, "pay method unavailable" unless Payment::AVAILABLE_CATEGORY[params[:category]][:pay_methods].find{|method| method[:name] == Payment::PAY_METHOD_WALLET}
#             item = Payment::AVAILABLE_CATEGORY[params[:category]][:class].constantize.find_uuid(params[:uuid])
#             raise ActiveRecord::RecordNotFound if item.user_id != @session_user.id
#             payment = "::Payment::#{params[:category].classify}Payment".constantize.create_payment(item, "wallet_pay")
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>payment:#{payment.inspect}".green
#             #钱包减余额
#           ActiveRecord::Base.transaction(isolation: :serializable) do
#               ::Account::Wallet.wastrel(@session_user, payment)
#             end
#             begin
#               payment.paid!
#               puts "API_V10::PaymentsAPI::property::wallet_pay====>钱包扣款成功".green
#             rescue Exception => ex
#               puts "API_V10::PaymentsAPI::property::wallet_pay::paid!====>Exception:回掉异常".red
#               puts "#{ex.message}".red
#               puts "#{ex.backtrace}".red
#             end
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>paid!调用成功".green
#             present true
#           rescue ActiveRecord::RecordNotFound
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:对象找不到".red
#             app_uuid_error
#           rescue OrderNoPay => ex
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:订单不能被支付".red
#             app_error("订单不能被支付", ex.message)
#           rescue Payment::CategoryUndefinedException => ex
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:订单类型错误".red
#             app_error("订单类型错误", ex.message)
#           rescue Payment::PayMethodUnavailableException => ex
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:支付方式不可用".red
#             app_error("支付方式不可用", ex.message)
#           rescue Account::Wallet::BalanceInsufficientException => ex
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:账户余额不足".red
#             app_error("账户余额不足", ex.message, -1)
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::wallet_pay====>Exception:系统错误".red
#             puts "#{ex.message}".red
#             puts "#{ex.backtrace}".red
#             server_error(ex)
#           ensure
#             puts "API_V10::PaymentsAPI::property::wallet_pay==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#         desc "微信支付（小程序）"
#         params do
#           requires :user_uuid, type: String, desc: '用户UUID'
#           requires :token, type: String, desc: '用户访问令牌'
#           requires :category, type: String, desc: "订单类型[#{Payment::AVAILABLE_CATEGORY.keys*"、"}]", default: 'shop_v2_order'#, values: Payment::AVAILABLE_CATEGORY
#           requires :uuid, type: String, desc: '订单UUID'
#         end
#         post 'wechat_pay_wxapp' do
#           authenticate_user
#           begin
#             puts "小程序API_V10::PaymentsAPI::property::wechat_pay==>BEGIN--------------------------------------------------------------------------------------------------".green
#             puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>params:#{params}".green
#             raise Payment::CategoryUndefinedException, "category invalid" unless Payment::AVAILABLE_CATEGORY.keys.include?(params[:category])
#             raise Payment::PayMethodUnavailableException, "pay method unavailable" unless Payment::AVAILABLE_CATEGORY[params[:category]][:pay_methods].find{|method| method[:name] == Payment::PAY_METHOD_WECHAT}
#             item = Payment::AVAILABLE_CATEGORY[params[:category]][:class].constantize.find_uuid(params[:uuid])
#             raise ActiveRecord::RecordNotFound if item.user_id != @session_user.id
#             payment = "::Payment::#{params[:category].classify}Payment".constantize.create_payment(item, ::Payment::PAY_METHOD_WECHAT)
#             puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>payment:#{payment.inspect}".green
#
#               WxPay.appid = 'wx873e5f9459580e38'
#               WxPay.key = 'mastergolf20140526weixinapimiyao'
#               WxPay.mch_id = '1248005401'
#
#             nonce_str = SecureRandom.uuid.tr('-', '')
#             openid = User::UserThirdPartyLogin.where(user_id: @session_user.id, category: "wechat").last.try(:openid)
#             pay_params = {
#               openid:           openid,
#               body:             payment.body.to_s,
#               out_trade_no:     payment.scode,
#               total_fee:        (payment.amount*100).to_i.to_s,
#               spbill_create_ip: '127.0.0.1',
#               notify_url:       ENV['WX_PAY_PAYMENT_NOTIFY_URL'],
#               trade_type:       'JSAPI',
#               nonce_str:        nonce_str,
#               time_expire:      payment.try{|item| item.expired_at.localtime.strftime("%Y%m%d%H%M%S")},
#             }
#             puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>pay_params:#{pay_params}".green
#             ret = WxPay::Service.invoke_unifiedorder pay_params
#
#
#             puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>ret:#{ret}".green
#             if ret.success?
#               puts "API_V10::PaymentsAPI::property::wechat_pay====>ret success".green
#               app_params = {prepayid: ret["prepay_id"], noncestr: nonce_str}
#               r = WxPay::Service::generate_js_pay_req app_params
#
#               puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>r:#{r}".green
#               r
#             else
#               puts "小程序API_V10::PaymentsAPI::property::wechat_pay====>支付请求创建失败".yellow
#               app_error("支付请求创建失败", "ret was not success")
#             end
#           rescue ActiveRecord::RecordNotFound
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:对象找不到".red
#             app_uuid_error
#           rescue OrderNoPay => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单不能被支付".red
#             app_error("订单不能被支付", ex.message)
#           rescue Payment::CategoryUndefinedException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单类型错误".red
#             app_error("订单类型错误", ex.message)
#           rescue Payment::AmountMismatchException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单金额不正确".red
#             app_error("订单金额不正确", ex.message)
#           rescue Payment::PayMethodUnavailableException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:支付方式不可用".red
#             app_error("支付方式不可用", ex.message)
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Backgrace:#{ex.backtrace}".red
#             server_error(ex)
#           ensure
#             puts "API_V10::PaymentsAPI::property::wechat_pay==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#         desc "获取微信JS签名包信息"
#         params do
#           optional :user_uuid, type: String, desc: '用户UUID'
#           optional :token, type: String, desc: '用户访问令牌'
#           requires :url, type: String, desc: '微信授权的url'
#         end
#         get 'wx_jssign_package' do
#           authenticate_user_if_signed_in
#           sign_package = $wx_auth.get_jssign_package(CGI::unescape(params[:url]))
#         end
#
#         desc "微信支付"
#         params do
#           requires :user_uuid, type: String, desc: '用户UUID'
#           requires :token, type: String, desc: '用户访问令牌'
#           requires :category, type: String, desc: "订单类型[#{Payment::AVAILABLE_CATEGORY.keys*"、"}]", default: 'shop_v2_order'#, values: Payment::AVAILABLE_CATEGORY
#           requires :uuid, type: String, desc: '订单UUID'
#           optional :trade_type, type: String, default: "APP", desc: '交易类型 JSAPI或APP， 默认APP'
#         end
#         post 'wechat_pay' do
#           authenticate_user
#           begin
#             puts "API_V10::PaymentsAPI::property::wechat_pay==>BEGIN--------------------------------------------------------------------------------------------------".green
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>params:#{params}".green
#             raise Payment::TradeTypeException, "trade type invalid" unless ['APP', 'JSAPI'].include?(params[:trade_type])
#             raise Payment::CategoryUndefinedException, "category invalid" unless Payment::AVAILABLE_CATEGORY.keys.include?(params[:category])
#             raise Payment::PayMethodUnavailableException, "pay method unavailable" unless Payment::AVAILABLE_CATEGORY[params[:category]][:pay_methods].find{|method| method[:name] == Payment::PAY_METHOD_WECHAT}
#             item = Payment::AVAILABLE_CATEGORY[params[:category]][:class].constantize.find_uuid(params[:uuid])
#             raise ActiveRecord::RecordNotFound if item.user_id != @session_user.id
#             case params[:trade_type]
#             when "JSAPI"
#               # JSAPI 需要传递OpenID给微信
#               open_id = UserThirdPartyLogin.where(category: "wechat", user_id: @session_user.id).first.try(:openid)
#               Helper.config_wechat_mp_pay
#               pay_method = ::Payment::PAY_METHOD_WECHAT_PUBLIC
#             else
#               Helper.config_wechat_pay
#               pay_method = ::Payment::PAY_METHOD_WECHAT
#             end
#             payment = "::Payment::#{params[:category].classify}Payment".constantize.create_payment(item, pay_method)
#
#             pay_params = {
#               body:             payment.body.to_s.first(16),
#               out_trade_no:     payment.scode,
#               total_fee:        (payment.amount*100).to_i.to_s,
#               spbill_create_ip: '127.0.0.1',
#               notify_url:       ENV['WX_PAY_PAYMENT_NOTIFY_URL'],
#               trade_type:       params[:trade_type],
#               nonce_str:        SecureRandom.uuid.tr('-', ''),
#               time_expire:      payment.try{|item| item.expired_at.localtime.strftime("%Y%m%d%H%M%S")}
#             }
#             pay_params[:openid] = open_id if open_id.present?
#
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>pay_params:#{pay_params}".green
#             ret = WxPay::Service.invoke_unifiedorder pay_params
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>ret:#{ret.inspect}".green
#             if ret.success?
#               puts "API_V10::PaymentsAPI::property::wechat_pay====>ret success".green
#               app_params = {prepayid: ret["prepay_id"], noncestr: pay_params[:nonce_str]}
#               r = case params[:trade_type]
#               when 'APP' then WxPay::Service::generate_app_pay_req(app_params)
#               when 'JSAPI' then WxPay::Service::generate_js_pay_req(app_params)
#               end
#               package = r.delete(:package)
#               r[:package_value] = package
#               puts "API_V10::PaymentsAPI::property::wechat_pay====>r:#{r}".green
#               r
#             else
#               puts "API_V10::PaymentsAPI::property::wechat_pay====>支付请求创建失败".yellow
#               app_error("支付请求创建失败", "ret was not success")
#             end
#           rescue ActiveRecord::RecordNotFound
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:对象找不到".red
#             app_uuid_error
#           rescue Payment::TradeTypeException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:无效的交易类型".red
#             app_error("无效的交易类型", ex.message)
#           rescue OrderNoPay => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单不能被支付".red
#             app_error("订单不能被支付", ex.message)
#           rescue Payment::CategoryUndefinedException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单类型错误".red
#             app_error("订单类型错误", ex.message)
#           rescue Payment::AmountMismatchException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:订单金额不正确".red
#             app_error("订单金额不正确", ex.message)
#           rescue Payment::PayMethodUnavailableException => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:支付方式不可用".red
#             app_error("支付方式不可用", ex.message)
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay====>Backgrace:#{ex.backtrace}".red
#             server_error(ex)
#           ensure
#             puts "API_V10::PaymentsAPI::property::wechat_pay==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#
#
#         desc "微信支付通知"
#         params do
#         end
#         post 'wechat_pay_notify' do
#           begin
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify==>BEGIN--------------------------------------------------------------------------------------------------".green
#             result = Hash.from_xml(request.body.read)["xml"]
#             ::Shop::WechatPayNotificationLog.create!(result)
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>result:#{result}".green
#
#             case result['trade_type']
#             when "JSAPI"
#               Helper.config_wechat_mp_pay
#             else
#               Helper.config_wechat_pay
#             end
#
#             if WxPay::Sign.verify?(result)
#               puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>验证成功".green
#               payment = Payment.find_by_scode(result["out_trade_no"])
#               puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>payment:#{payment.inspect}".green
#               payment.update_attribute(:platform_scode, result["transaction_id"])
#               begin
#                 payment.paid!
#                 puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>paid!调用成功".green
#               rescue Exception => ex
#                 puts "API_V10::PaymentsAPI::property::wechat_pay_notify::paid!====>Exception:回掉异常".red
#                 puts "API_V10::PaymentsAPI::property::wechat_pay_notify::paid!====>Message:#{ex.message}".red
#                 puts "API_V10::PaymentsAPI::property::wechat_pay_notify::paid!====>Backgrace:#{ex.backtrace}".red
#               end
#               status 200
#               present 'success'
#             else
#               puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>验证失败".yellow
#               present 'failure'
#             end
#           rescue AASM::InvalidTransition
#             if payment.paided
#               status 200
#               present 'success'
#             else
#               puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>Exception:订单状态错误".red
#               present 'failure'
#             end
#           rescue ActiveRecord::RecordNotFound
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>Exception:对象找不到".red
#             present 'failure'
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify====>Backgrace:#{ex.backtrace}".red
#           ensure
#             puts "API_V10::PaymentsAPI::property::wechat_pay_notify==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#         desc "银联支付"
#         params do
#           requires :user_uuid, type: String, desc: '用户UUID'
#           requires :token, type: String, desc: '用户访问令牌'
#           requires :category, type: String, desc: "订单类型[#{Payment::AVAILABLE_CATEGORY.keys*"、"}]", default: 'shop_v2_order'#, values: Payment::AVAILABLE_CATEGORY
#           requires :uuid, type: String, desc: '订单UUID'
#         end
#         post 'union_pay' do
#           authenticate_user
#           begin
#             puts "API_V10::PaymentsAPI::property::union_pay==>BEGIN--------------------------------------------------------------------------------------------------".green
#             puts "API_V10::PaymentsAPI::property::union_pay====>params:#{params}".green
#             raise Payment::CategoryUndefinedException, "category invalid" unless Payment::AVAILABLE_CATEGORY.keys.include?(params[:category])
#             raise Payment::PayMethodUnavailableException, "pay method unavailable" unless Payment::AVAILABLE_CATEGORY[params[:category]][:pay_methods].find{|method| method[:name] == Payment::PAY_METHOD_UNIONPAY}
#             item = Payment::AVAILABLE_CATEGORY[params[:category]][:class].constantize.find_uuid(params[:uuid])
#             raise ActiveRecord::RecordNotFound if item.user_id != @session_user.id
#             payment = "::Payment::#{params[:category].classify}Payment".constantize.create_payment(item, ::Payment::PAY_METHOD_UNIONPAY)
#             puts "API_V10::PaymentsAPI::property::union_pay====>payment:#{payment.inspect}".green
#
#             Helper.config_unionpay ENV['UNION_PAY_PAYMENT_NOTIFY_URL']
#
#             options = UnionpayApp::Service.sign((payment.amount.to_f * 100).to_i.to_s, payment.scode, payment.try{|item| item.expired_at.localtime}, payment.created_at)
#
#             tn = UnionpayApp::Service.post(options)
#             puts "API_V10::PaymentsAPI::property::union_pay====>payment:#{tn.inspect}".green
#             unless tn.blank?
#               {transmitnumber: tn, model: "00"}
#             else
#               puts "API_V10::PaymentsAPI::property::union_pay====>支付请求创建失败".yellow
#               app_error("支付请求创建失败", "tn is blank")
#             end
#           rescue OrderNoPay => ex
#             puts "API_V10::PaymentsAPI::property::union_pay====>Exception:订单不能被支付".red
#             app_error("订单不能被支付", ex.message)
#           rescue Payment::CategoryUndefinedException => ex
#             puts "API_V10::PaymentsAPI::property::union_pay====>Exception:订单类型错误".red
#             app_error("订单类型错误", ex.message)
#           rescue Payment::PayMethodUnavailableException => ex
#             puts "API_V10::PaymentsAPI::property::union_pay====>Exception:支付方式不可用".red
#             app_error("支付方式不可用", ex.message)
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::union_pay====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::union_pay====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::union_pay====>Backgrace:#{ex.backtrace}".red
#             server_error(ex)
#           ensure
#             puts "API_V10::PaymentsAPI::property::union_pay==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#         desc "银联支付通知"
#         params do
#         end
#         post 'union_pay_notify' do
#           puts "API_V10::PaymentsAPI::property::union_pay_notify==>BEGIN--------------------------------------------------------------------------------------------------".green
#           puts "API_V10::PaymentsAPI::property::union_pay_notify====>params:#{params}".green
#           Helper.config_unionpay ENV['UNION_PAY_PAYMENT_NOTIFY_URL']
#           notify_params = Helper.unionpay_params params
#           ::Shop::UnionPayNotificationLog.create!(notify_params)
#           puts "API_V10::PaymentsAPI::property::union_pay_notify====>notify_params:#{notify_params}".green
#           begin
#             if UnionpayApp::Service.verify notify_params
#               puts "API_V10::PaymentsAPI::property::union_pay_notify====>验证成功".green
#               payment = Payment.find_by_scode(params["orderId"])
#               raise Payment::AmountMismatchException, "amount does not match the group_total_fee" if (payment.amount.to_f * 100).to_i.to_s != params["txnAmt"].to_s
#               payment.update_attribute(:platform_scode, notify_params["queryId"])
#               puts "API_V10::PaymentsAPI::property::union_pay_notify====>paid!调用成功".green
#               begin
#                 payment.paid!
#               rescue Exception => ex
#                 puts "API_V10::PaymentsAPI::property::union_pay_notify::paid!====>Exception:回掉异常".red
#                 puts "API_V10::PaymentsAPI::property::union_pay_notify::paid!====>Message:#{ex.message}".red
#                 puts "API_V10::PaymentsAPI::property::union_pay_notify::paid!====>Backgrace:#{ex.backtrace}".red
#               end
#               status 200
#               present 'success'
#             else
#               puts "API_V10::PaymentsAPI::property::union_pay_notify====>验证失败".yellow
#               present 'error'
#             end
#           rescue AASM::InvalidTransition
#             if payment.paided
#               status 200
#               present 'success'
#             else
#               puts "API_V10::PaymentsAPI::property::union_pay_notify====>Exception:订单状态错误".red
#               present 'error'
#             end
#           rescue Payment::AmountMismatchException
#             puts "API_V10::PaymentsAPI::property::union_pay_notify====>Exception:订单金额不匹配".red
#             present 'error'
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::union_pay_notify====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::union_pay_notify====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::union_pay_notify====>Backgrace:#{ex.backtrace}".red
#             present 'error'
#           ensure
#             puts "API_V10::PaymentsAPI::property::union_pay_notify==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#
#         desc "支付宝支付"
#         params do
#           requires :user_uuid, type: String, desc: '用户UUID'
#           requires :token, type: String, desc: '用户访问令牌'
#           requires :category, type: String, desc: "订单类型[#{Payment::AVAILABLE_CATEGORY.keys*"、"}]", default: 'shop_v2_order'#, values: Payment::AVAILABLE_CATEGORY
#           requires :uuid, type: String, desc: '订单UUID'
#         end
#         post 'ali_pay' do
#           authenticate_user
#           begin
#             puts "API_V10::PaymentsAPI::property::ali_pay==>BEGIN--------------------------------------------------------------------------------------------------".green
#             puts "API_V10::PaymentsAPI::property::ali_pay====>params:#{params}".green
#             raise Payment::CategoryUndefinedException, "category invalid" unless Payment::AVAILABLE_CATEGORY.keys.include?(params[:category])
#             raise Payment::PayMethodUnavailableException, "pay method unavailable" unless Payment::AVAILABLE_CATEGORY[params[:category]][:pay_methods].find{|method| method[:name] == Payment::PAY_METHOD_ALIPAY}
#             item = Payment::AVAILABLE_CATEGORY[params[:category]][:class].constantize.find_uuid(params[:uuid])
#             raise ActiveRecord::RecordNotFound if item.user_id != @session_user.id
#             payment = "::Payment::#{params[:category].classify}Payment".constantize.create_payment(item, ::Payment::PAY_METHOD_ALIPAY)
#             puts "API_V10::PaymentsAPI::property::ali_pay====>payment:#{payment.inspect}".green
#
#             Helper.config_alipay
#
#             pay_params = {
#               out_trade_no: payment.scode,
#               notify_url: ENV['ALI_PAY_PAYMENT_NOTIFY_URL'],
#               subject: payment.body.to_s.first(200),
#               total_fee: payment.amount.round(2).to_s,
#               body: "佰佳高尔夫",
#               it_b_pay: payment.try{|item| [(item.expired_at or Time.now), Time.now + 10.days].min.localtime.strftime("%Y-%m-%d %H:%M:%S")},
#             }
#             puts "API_V10::PaymentsAPI::property::ali_pay====>pay_params:#{pay_params}".green
#             ret = Alipay::Mobile::Service.mobile_securitypay_pay_string(
#               pay_params
#             )
#             puts "API_V10::PaymentsAPI::property::ali_pay====>ret:#{ret.inspect}".green
#             unless ret.blank?
#               ret
#             else
#               puts "API_V10::PaymentsAPI::property::ali_pay====>支付请求创建失败".yellow
#               app_error("支付请求创建失败", "ret is blank")
#             end
#           rescue OrderNoPay => ex
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Exception:订单不能被支付".red
#             app_error("订单不能被支付", ex.message)
#           rescue Payment::CategoryUndefinedException => ex
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Exception:订单类型错误".red
#             app_error("订单类型错误", ex.message)
#           rescue Payment::PayMethodUnavailableException => ex
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Exception:支付方式不可用".red
#             app_error("支付方式不可用", ex.message)
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::ali_pay====>Backgrace:#{ex.backtrace}".red
#             server_error(ex)
#           end
#         end
#
#         desc "支付宝支付通知"
#         params do
#         end
#         post 'ali_pay_notify' do
#           puts "API_V10::PaymentsAPI::property::ali_pay_notify==>BEGIN--------------------------------------------------------------------------------------------------".green
#           puts "API_V10::PaymentsAPI::property::ali_pay_notify====>params:#{params}".green
#
#           Helper.config_alipay
#
#           notify_params = Helper.alipay_params params
#           puts "API_V10::PaymentsAPI::property::ali_pay_notify====>notify_params:#{notify_params}".green
#
#           trade_type = params["type"] == 'app' ? 1 : 2
#           success = false
#           verified = false
#
#           if (Alipay::Notify.verify?(notify_params))
#             case notify_params["trade_status"]
#             when 'TRADE_SUCCESS' then success = true
#             when 'TRADE_FINISHED' then success = true
#             end
#             verified = true
#           end
#           ::Shop::AliPayNotificationLog.create!(notify_params.merge({ "trade_type" => trade_type, "verified" => verified }))
#           begin
#             if success and verified
#               puts "API_V10::PaymentsAPI::property::ali_pay_notify====>验证通过".green
#               payment = Payment.find_by_scode(notify_params["out_trade_no"])
#               puts "API_V10::PaymentsAPI::property::ali_pay_notify====>payment:#{payment.inspect}".green
#               raise Payment::AmountMismatchException, "amount does not match the total_fee" if payment.amount.to_f != params["total_fee"].to_f
#               payment.update_attribute(:platform_scode, notify_params["trade_no"])
#               begin
#                 payment.paid!
#                 puts "API_V10::PaymentsAPI::property::ali_pay_notify====>paid!调用成功".green
#               rescue Exception => ex
#                 puts "API_V10::PaymentsAPI::property::ali_pay_notify::paid!====>Exception:回掉异常".red
#                 puts "API_V10::PaymentsAPI::property::ali_pay_notify::paid!====>Message:#{ex.message}".red
#                 puts "API_V10::PaymentsAPI::property::ali_pay_notify::paid!====>Backgrace:#{ex.backtrace}".red
#               end
#               status 200
#               present 'success'
#             else
#               present 'failure'
#               puts "API_V10::PaymentsAPI::property::ali_pay_notify====>验证失败".yellow
#             end
#           rescue AASM::InvalidTransition
#             if payment.paided
#               status 200
#               present 'success'
#             else
#               puts "API_V10::PaymentsAPI::property::ali_pay_notify====>Exception:订单状态错误".red
#               present 'failure'
#             end
#           rescue Payment::AmountMismatchException
#             puts "API_V10::PaymentsAPI::property::ali_pay_notify====>Exception:订单金额不匹配".red
#             present 'failure'
#           rescue Exception => ex
#             puts "API_V10::PaymentsAPI::property::ali_pay_notify====>Exception:系统错误".red
#             puts "API_V10::PaymentsAPI::property::ali_pay_notify====>Message:#{ex.message}".red
#             puts "API_V10::PaymentsAPI::property::ali_pay_notify====>Backgrace:#{ex.backtrace}".red
#             present 'failure'
#           ensure
#             puts "API_V10::PaymentsAPI::property::ali_pay_notify==>END--------------------------------------------------------------------------------------------------".green
#           end
#         end
#       end
#     end
#   end
# end
