module V1
  module Mall
    class CollectionsAPI < Grape::API
      namespace :mall do
        resources :collections do
          
          desc "收藏某个商品"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          put do
            begin
              authenticate_user
              style = ::Mall::Style.find_uuid(params[:style_uuid])
              @session_user.collections.find_or_create_by!(item: style)
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "收藏的商品"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get do
            begin
              authenticate_user
              present @session_user.mall_styles, with: ::V1::Entities::Mall::ProductsByStyles
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "取消收藏"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          delete do
            begin
              authenticate_user
              style = ::Mall::Style.find_uuid(params[:style_uuid])
              @session_user.collections.where(item: style).destroy_all
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
