module V1
  module User
    class SessionsAPI < Grape::API
      namespace :user do 
        resources :sessions do
          
          desc "获取登录短信验证码"
          params do
            requires :phone, type: String, desc: "手机号"
          end
          get :captcha do
            begin
              app_error("无效的手机号码，请重新输入", "Invalid phone number") unless valid_phone?
              user = ::Account::User.find_or_create_by!(phone: params[:phone])
              app_error("验证码每小时内最多5条，请稍后再试", "Captcha out of gauge") if user.login_captchas.over_hourly_limited?
              app_error("验证码已超出今日上限", "Captcha out of gauge") if user.login_captchas.over_limited?
              app_error('此手机号的验证码已超出今日上限', "The phone number's verification code is beyond the limit of today") if ::Account::Captcha.over_one_phone_limited?(user.phone)
              app_error("获取验证码过于频繁，请稍后再试", "Please try again later") if user.login_captchas.frequent?
              captcha = ::Account::Captchas::LoginCaptcha.generate!(user.phone)
              user.send_sms('SMS_131030131', code: captcha.code)
              { tips: "验证码已发送，有效期为10分钟，请注意查收" }
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          
          desc "验证码登录"
          params do
            requires :phone, type: String, desc: "手机号"
            requires :captcha, type: String, desc: "验证码"
          end
          post :captcha_login do
            begin
              app_error("无效的手机号码，请重新输入", "Invalid phone number") unless valid_phone?
              app_error("验证码格式错误，应为4位数字", "Invalid captcha") unless valid_captcha?
              user = ::Account::User.find_or_create_by!(phone: params[:phone])
              app_error("验证码错误", "Invalid captcha") unless user.valid_login_captcha?(params[:captcha])
              token = user.phone_login!
              client_info_record(request, token)
              ::Operate::CommuneHandler.work_score user, nil
              present user, with: ::V1::Entities::User::UserForLogin, token: token.token
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc '微信登录'
          params do
            requires :code, type: String, desc: "access_token 票据"
            optional :type, type: String, values: ['jsapi' ,'app'], default: 'app', desc: "接口类型"
            optional :inviter_uuid, type: String, desc: '分享者 UUID'
          end
          post :wechat_login do
            begin
              wx_auth = params[:type] == 'app' ? $wx_open_auth : $wx_mp_auth
              access_info = wx_auth.get_oauth_access_token(params[:code])
              app_error("获取用户授权失败", 'WX oauth2 access denied') unless access_info.ok?
              user_info = wx_auth.get_oauth_userinfo(access_info.result['openid'], access_info.result['access_token'])
              app_error("获取用户信息失败", 'WX user info access denied') unless user_info.ok?
              user_and_token = ::Account::User.wx_unionid_login!(user_info.result, params[:type])
              client_info_record(request, user_and_token[1])
              inviter_user = ::Account::User.find_uuid params[:inviter_uuid] rescue nil
              logger.info "====================inviter_user========#{inviter_user.try(:uuid)}"
              logger.info "====================user========#{(user_and_token[0]).uuid}"
              logger.info "====================count========#{(user_and_token[0]).tokens.count}"
              ::Operate::CommuneHandler.work_score user_and_token[0], inviter_user
              present user_and_token[0], with: ::V1::Entities::User::UserForLogin, token: user_and_token[1].token
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
    end
  end
end
