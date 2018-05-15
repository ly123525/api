module V1
  module Mall
    class IndexsAPI < Grape::API
      namespace :mall do
        resources :indexs do
          desc "商城首页"
          params do 
            optional :user_uuid, type: String, desc: '用户UUID'
          end  
          get do
            begin 
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              app_version_code=app_version_code(request).to_i
              mall_index = ::Mall::Indices::Index.where("version_code > ? ", app_version_code).last || ::Mall::Indices::Index.where("version_code <= ? ", app_version_code).first
              styles = ::Mall::Style.recommended.joins(:product).where('mall_products.on_sale is true').sorted.limit(10)
              present mall_index, with: ::V1::Entities::Mall::MallIndex, styles: styles
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end  
          end
          desc "首页商品推荐分页"
          params do
            requires :page, type: Integer, default: 2, desc: '分页页码'
          end
          get :page do
            begin
              styles = ::Mall::Style.recommended.joins(:product).where('mall_products.on_sale is true').sorted.page(params[:page]).per(10)
              inner_app = true if inner_app?
              present styles, with: ::V1::Entities::Mall::SimpleProductByStyle, inner_app: inner_app
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