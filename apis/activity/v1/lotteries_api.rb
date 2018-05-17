module V1
  module Activity
    class LotteriesAPI < Grape::API
      namespace :activity do
        resources :lotteries do
          desc "用户奖券列表"
          params do 
            requires :user_uuid, type: String, desc: '用户 UIID'
            requires :token, type: String, desc: '用户访问令牌'
          end  
          get do
            begin
              authenticate_user
              
            rescue Exception => ex
              server_error(ex)                          
            end
          end  
        end
      end
    end
  end
end          