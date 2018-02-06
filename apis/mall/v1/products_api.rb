module V1
  module Mall
    class ProductsAPI < Grape::API
      namespace :mall do
        resources :products do
          
          desc "商品详情"
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
          
          desc "选择款式"
          params do
            optional :user_uuid, type: String, desc: "用户 UUID"
            requires :uuid, type: String, desc: '商品 UUID'
            optional :labels, type: Array[String], desc: "url 参数：labels[]=红色&labels[]=41码"
          end
          get :style do
            begin
              product = ::Mall::Product.with_deleted.find_uuid(params[:uuid])
              style = product.get_style_by_labels(params[:labels])
              styles_for_choice = product.styles_for_choice(params[:labels])
              present product, with: ::V1::Entities::Mall::ProductForChoice, style: style, styles_for_choice: styles_for_choice
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
