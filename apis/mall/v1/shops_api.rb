module V1
  module Mall
    class ShopsAPI < Grape::API
      namespace :mall do
        resources :shops do
          desc "店铺首页"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :uuid, type: String, desc: '店铺UUID'
            requires :sort_rule, type: String, default: 'all', values: ['all', 'newest', 'sales_volumn', 'lowest_price', 'highest_price'], desc: '排序规则'
            requires :page, type: Integer, default: 1, desc: '页码'
          end
          get do
            begin
              shop = ::Mall::Shop.find_uuid(params[:uuid])
              styles = ::Mall::Style.recommended.includes(:product).where("mall_products.on_sale = ?", true).references(:product).includes(:shop).where("mall_shops.id = ?", shop.id).order_by(params[:sort_rule]).page(params[:page]).per(20)
              # styles = shop.styles.on_sale_by_product.order_by(params[:sort_rule]).page(params[:page]).per(20)
              ::Operate::CommuneHandler.activity_style_for_tags styles
              ::Operate::LotteryHandler.activity_style_for_tags styles
              inner_app = inner_app? request
              present shop, with: ::V1::Entities::Mall::HomePageOfShop, styles: styles, inner_app: inner_app
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