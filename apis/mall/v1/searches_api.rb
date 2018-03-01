module V1
  module Mall
    class SearchesAPI < Grape::API
      namespace :mall do
        resources :searches do
          
          desc "历史记录"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          get :history do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              histories = user.mall_searches.order(created_at: :desc).pluck(:content) rescue []
              { histories: histories, recommends: ::SearchRecommend.all.pluck(:content) }
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
          get do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              user.mall_searches.find_or_create_by(params[:keywords]) rescue nil
              styles = ::Mall::Style.joins(:product).search(params[:keywords]).order_by(params[:sort_rule]).page(params[:page]).per(20)
              present styles, with: ::V1::Entities::Mall::SimpleProduct
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
      
    end
  end
end
