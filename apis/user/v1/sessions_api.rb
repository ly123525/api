module V1
  module User
    class SessionsAPI < Grape::API
      namespace :user do 
        resources :sessions do
          
          helpers do
            def valid_phone?
              return if params[:phone].blank?
              (params[:phone] =~ /^1\d{10}$/).present?
            end
            
            def valid_captcha?
              return if params[:captcha].blank?
              (params[:captcha] =~ /^\d{4}$/).present?
            end
          end
          
          desc "获取登录短信验证码" ,{
            headers: {
              signature: {
                description: '验证签名',
                required: true
              },
              timestamp: {
                description: '时间戳',
                required: true
              }
            },
            consumes: [ 'application/x-www-form-urlencoded' ]
          }
          params do
            requires :phone, type: String, desc: "手机号"
          end
          get :captcha do
            begin
              app_error("无效的手机号码，请重新输入", "Invalid phone number") unless valid_phone?
              user = ::Account::User.find_or_create_by!(phone: params[:phone])
              app_error("验证码已超出今日上限", "Captcha out of gauge") if user.login_captchas.today.count>=::Account::Captcha::TODAY_MAX_COUNT
              app_error("获取验证码过于频繁，请稍后再试", "Please try again later") if ::Account::Captchas::LoginCaptcha.frequent?(params[:phone])
              captcha = ::Account::Captchas::LoginCaptcha.generate!(user.phone)
              { tips: "验证码已发送，请注意查收#{captcha.code}", user_uuid: user.uuid }
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          
          desc "验证码登录" ,{
          headers: {
            signature: {
              description: '验证签名',
              required: true
            },
            timestamp: {
              description: '时间戳',
              required: true
            }
          },
          consumes: [ 'application/x-www-form-urlencoded' ]
        }
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
            {user_uuid: user.uuid, token: user.login!.token}
          rescue Exception => ex
            server_error(ex)
          end
        end
          
      end
    end
  end
end
end
