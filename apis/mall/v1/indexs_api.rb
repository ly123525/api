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
              mall_index = ::Mall::Indices::Index.current_mall_index app_version_code
              styles = ::Mall::Style.on_sale_by_product.sorted.limit(20)
              operate_style_ids = Operate::CommuneHandler.operate_styles.ids
              ::Mall::Style.activity_style_for_tags styles, operate_style_ids
              inner_app = inner_app? request
              present mall_index, with: ::V1::Entities::Mall::MallIndex, styles: styles, inner_app: inner_app
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
              styles = ::Mall::Style.on_sale_by_product.sorted.page(params[:page]).per(20)
              operate_style_ids = Operate::CommuneHandler.operate_styles.ids
              ::Mall::Style.activity_style_for_tags styles, operate_style_ids
              inner_app = inner_app? request
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