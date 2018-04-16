module V1
  module User
    class UsersAPI < Grape::API
      namespace :user do
        resources :users do
          
          helpers do
            def valid_nickname?
              (2..12).include? params[:nickname].size
            end
          end
          
          desc "个人中心"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :personal_center do
            begin
              authenticate_user
              present @session_user, with: ::V1::Entities::User::PersonalCenter
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "设置头像"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :image, type: File, desc: '头像'
          end
          patch :head_image do
            begin
              logger.info"================================params=#{params}.to_s"
              authenticate_user
              logger.info"================================user=#{user.name}"
              picture = ::Picture.find_or_create_by(imageable: @session_user)
              picture.update!(image: params[:image])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "修改昵称"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :nickname, type: String, desc: '昵称'
          end
          patch :nickname do
            begin
              authenticate_user
              app_error("昵称长度有误！应为2至12个字符，中文、英文各占一个字符", "Nickname length out of range") unless valid_nickname?
              @session_user.update!(nickname: params[:nickname])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "修改性别"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :sex, type: String, values: ['男', '女'], desc: '性别[男、女]'
          end
          patch :sex do
            begin
              authenticate_user
              @session_user.update!(sex: params[:sex])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "友盟 Token 绑定"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :umeng_token, type: String, desc: '友盟 token'
          end
          patch :umeng_token do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              user.update!(umeng_token: params[:umeng_token])
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "意见反馈"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '友盟 token'
            requires :content, type: String, desc: '内容'
          end
          post :feedback do
            begin
              authenticate_user
              @session_user.feedbacks.create(content: params[:content])
              { tips: '感谢您的宝贵意见' }
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "用户协议"
          params do 
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'            
          end
          get :agreement do
            begin
              authenticate_user
              {scheme:  "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/agreement")}
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
