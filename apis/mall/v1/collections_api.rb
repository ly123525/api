module V1
  module Mall
    class CollectionsAPI < Grape::API
      namespace :mall do
        resources :collections do
          
          desc "收藏商品"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              style = ::Mall::Style.with_deleted.find_uuid(params[:style_uuid])
              present style, with: ::V1::Entities::Mall::ProductByStyle, user: user
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
