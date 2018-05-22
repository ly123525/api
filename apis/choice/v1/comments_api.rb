module V1
  module Choice
    class CommentsAPI < Grape::API
      namespace :choice do
        resources :comments do
          desc  "评论列表"
          params do
            requires :article_uuid, type: String,  desc: "文章 UUID"
            optional :page, type: Integer, default: 1, desc: '分页页码'
          end
          get do
            begin
              article = ::Choice::Article.find_uuid(params[:article_uuid])
              comments = article.comments.page(params[:page]).per(20)
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
              app_error("评论内容不能为空", "Comments cannot be empty") if params[:content].blank?
              authenticate_user
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