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
              authenticate_user
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
        end
      end
      
    end
  end
end
