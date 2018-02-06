module V1
  module Mall
    class ShopsAPI < Grape::API
      namespace :mall do
        resources :shops do
          
          desc "陪聊接待窗口"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '商铺 UUID'
            optional :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get :service do
            begin
              authenticate_user
              shop = ::Mall::Shop.find_uuid(params[:uuid])
              product = shop.styles.find_uuid(params[:style_uuid])
              @session_user.hx_register
              present shop, with: ::V1::Entities::Mall::ShopForService
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
