module V1
  module Choice
    class ArticlesAPI < Grape::API
      namespace :choice do
        resources :articles do
          desc "精选文章列表"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            optional :page, type: Integer, default: 1, desc: '页数'
          end
          get do
            begin
              articles = ::Choice::Article.visible.sorted
              present articles, with: ::V1::Entities::Choice::Articles
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
      
    end
  end
end
