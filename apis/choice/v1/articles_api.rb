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
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              article_ids = user.good_lauds.pluck(:article_id) rescue []
              articles = ::Choice::Article.visible.sorted.page(params[:page]).per(10)
              inner_app = inner_app? request
              present articles, with: ::V1::Entities::Choice::Articles, article_ids: article_ids, inner_app: inner_app
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "点赞/取消"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '文章 UUID'
            requires :cancelled, type: Boolean, default: false, desc: 'true为取消点赞'
          end
          put :good do
            begin
              authenticate_user
              article = ::Choice::Article.find_uuid(params[:uuid])
              if params[:cancelled]
                article.lauds.where(user: @session_user).destroy_all rescue nil
              else
                article.lauds.find_or_create_by(user: @session_user).update(type: ::Choice::Lauds::Good.name)
              end
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "点差/取消"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '文章 UUID'
            optional :cancelled, type: Boolean, default: false, desc: 'true为取消点差'
          end
          put :bad do
            begin
              authenticate_user
              article = ::Choice::Article.find_uuid(params[:uuid])
              if params[:cancelled]
                article.lauds.where(user: @session_user).destroy_all rescue nil
              else
                article.lauds.find_or_create_by(user: @session_user).update(type: ::Choice::Lauds::Bad.name)
              end
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "分享统计"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '文章 UUID'
          end
          post :share_statistic do
            begin
              authenticate_user
              article = ::Choice::Article.find_uuid(params[:uuid])
              ::ShareStatistic.find_or_create_by(item: article, user: @session_user)
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end

          desc "详情页"
          params do
            requires :uuid, type: String, desc: '文章 UUID'
            optional :user_uuid, type: String, desc: '用户 UUID'
          end

          get 'detail'  do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              article = ::Choice::Article.find_uuid(params[:uuid])
              good_article_ids = user.good_lauds.pluck(:article_id) rescue []
              bad_article_ids = user.bad_lauds.pluck(:article_id) rescue []
              user_ids = article.collections.pluck(:user_id) rescue []
              user_id = user.id rescue nil
              inner_app = inner_app? request
              present article, with: ::V1::Entities::Choice::Article, good_article_ids: good_article_ids, bad_article_ids: bad_article_ids, user_ids: user_ids, user_id: user_id, inner_app: inner_app
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
