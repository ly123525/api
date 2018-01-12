module V1
  module Shop
    class ProductsAPI < Grape::API
      namespace :shop do
        resources :products do
          
          desc "商品详情"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            optional :token, type: String, desc: '用户访问令牌'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get do
            # begin
#
#             rescue Exception => ex
#               server_error(ex)
#             end
present ::Account::User.first, with: ::V1::Entities::Shop::Products
          end
        end
      end
      
    end
  end
end
