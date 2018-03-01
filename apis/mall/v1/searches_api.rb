module V1
  module Mall
    class SearchesAPI < Grape::API
      namespace :mall do
        resources :searches do
          
          desc "历史记录"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :history do
            begin
              authenticate_user
              { 
                histories: ::Searches::MallSearch.order(created_at: :desc).pluck(:content),
                recommends: ::SeawrchRecommend.all.pluck(:content)
              }
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
      
    end
  end
end
