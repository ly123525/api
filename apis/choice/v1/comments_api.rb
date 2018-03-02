module V1
  module Choice
    class CommentsAPI < Grape::API
      namespace :choice do
        resources :comments do
          desc  "评论列表"
          params do
            requires :article_uuid, type: String,  desc: "文章 UUID"
          end
          get do
            begin
              article = ::Choice::Article.find_uuid(params[:article_uuid])
              comments = article.comments
              present comments, with: ::V1::Entities::Choice::Comments
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end

          desc "创建评论"
          params do
            requires :article_uuid, type:String, desc: '文章 UUID'
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :content, type: String, desc: '评论内容'
          end
          post do
            begin
              authenticate_user
              # @session_user = ::Account::User.find_uuid(params[:user_uuid])
              article = ::Choice::Article.find_uuid(params[:article_uuid])
              comment=article.comments.new(user_id: @session_user.id, content: params[:content])
              comment.save!
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