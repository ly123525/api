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
          end
          
          desc "获取登录短信验证码" do
            headers signature: {
              description: '验证签名',
              required: true
            },
            timestamp: {
              description: '时间戳',
              required: true
            }
          end
          params do
            requires :phone, type: String, desc: "手机号"
          end
          get :captcha do
            # user = User.without
            # user = User.without_deleted.find_or_create(params[:phone])
#             return { code: 30101 } if ::AppInfoHelper.app_version(request).nil?
#             return { code: 30101 } unless valid_phone?
#             return { code: 30107 } if user.captchas.today.count > 5
#
#
#             captcha = user.captchas.generate('signin')
#             user.send_captcha_sms(captcha.content)
#
#             { code: 10000 }
          end
        end
      end
      
    end
  end
end
