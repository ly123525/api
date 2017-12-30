module V1
  module User
    class UsersAPI < Grape::API
      namespace :user do 
        resources :users do
          
          desc "查看用户信息" do
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
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get do

          end
        end
      end
      
    end
  end
end
