module V1
  module Choice
    class CollectionsAPI < Grape::API
      namespace :choice do
        resources :collections do
          desc "收藏某篇文章"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :article_uuid, type: String, desc: '文章 UUID'
          end

          put do
            begin
              authenticate_user
              article = ::Choice::Article.find_uuid(params[:article_uuid])
              @session_user.collections.find_or_create_by!(item: article)
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end

          desc "文章收藏列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get do
            begin
              authenticate_user
              @session_user = ::Account::User.find_uuid(params[:user_uuid])
              present @session_user.choice_articles, with: ::V1::Entities::Choice::ChoiceArticles
            rescue Exception => ex
              server_error(ex)
            end
          end

          desc "取消收藏"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :article_uuid, type: String, desc: '文章 UUID'
          end
          delete do
            begin
              authenticate_user
              article = ::Choice::Article.find_uuid(params[:article_uuid])
              @session_user.collections.where(item: article).destroy_all
              { result: true }
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