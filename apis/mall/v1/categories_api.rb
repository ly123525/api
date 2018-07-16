module V1
  module Mall
    class CategoriesAPI < Grape::API
      namespace :mall do
        resources :categories do
          desc "平台分类"
          params do
          end
          get do
            begin
              categories = ::Mall::ProductCategory.roots
              present categories, with: ::V1::Entities::Categories
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end

          desc "商品分类下的商品列表"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :uuid, type: String, desc: '商品分类 UUID'
            requires :sort_rule, type: String, default: 'all', values: ['all', 'newest', 'sales_volumn', 'lowest_price', 'highest_price'], desc: '排序规则'
            requires :page, type: Integer, default: 1, desc: '页码'
          end
          get :products do
            begin
              user = ::Account::User.find_uuid params[:user_uuid] rescue nil
              product_category = ::Mall::ProductCategory.find_uuid params[:uuid]
              styles = ::Mall::Style.recommended.includes(:product).where('mall_products.on_sale is true and mall_products.product_category_id = ?', product_category.id).references(:product).search_by_keywords(params[:keywords]).order_by(params[:sort_rule]).page(params[:page]).per(20)
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
