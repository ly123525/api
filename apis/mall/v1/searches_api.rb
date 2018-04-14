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
              histories = user.mall_searches.order(created_at: :desc).limit(20).pluck(:content) rescue []
              { histories: histories, recommends: ::SearchRecommend.all.pluck(:content) }
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "删除历史"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          delete :history do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              user.mall_searches.destroy_all 
              true
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
