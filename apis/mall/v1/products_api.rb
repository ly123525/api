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
          
          desc "商品描述"
          params do
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get :details do
            begin
              style = ::Mall::Style.with_deleted.find_uuid(params[:style_uuid])
              style.product.details
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
          
          desc "搜索商品"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :keywords, type: String, desc: '关键词'
            requires :sort_rule, type: String, default: 'all', values: ['all', 'new', 'sales_volumn', 'lowest_price', 'highest_price'], desc: '排序规则'
            requires :page, type: Integer, default: 1, desc: '页码'
          end
          get :search do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              user.mall_searches.find_or_create_by(content: params[:keywords]) rescue nil
              styles = ::Mall::Style.joins(:product).search(params[:keywords]).order_by(params[:sort_rule]).page(params[:page]).per(20)
              present styles, with: ::V1::Entities::Mall::SimpleProductByStyle
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "商品评论列表"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
            requires :page, type: Integer, default: 1, desc: '页码'
          end
          get :comments do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              style= ::Mall::Style.find_uuid(params[:style_uuid])
              comments = style.product.comments.page(params[:page]).per(20)
              present comments, with: ::V1::Entities::Mall::Comments
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
