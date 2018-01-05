module V1
  module User
    class UsersAPI < Grape::API
      namespace :user do
        resources :users do
          
          desc "个人中心" ,
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
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :personal_center do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              present user, with: ::V1::Entities::User::PersonalCenter
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
      
    end
  end
end
