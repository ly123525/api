module V1
  module Mall
    class CategoriesAPI < Grape::API
      namespace :mall do
        resources :categories do
          desc "平台分类"
          get do
            begin
              categories = ::Mall::ProductCategory.roots.order(lft: :asc)
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
              category = ::Mall::ProductCategory.find_uuid params[:uuid]
              product_ids = category.product_ids_by_search
              styles = ::Mall::Style.recommended.includes(:product).where(product_id: product_ids).order_by(params[:sort_rule]).references(:product).page(params[:page]).per(20)
              ::Operate::CommuneHandler.activity_style_for_tags styles
              ::Operate::LotteryHandler.activity_style_for_tags styles
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
