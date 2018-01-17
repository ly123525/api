module V1
  module User
    class UsersAPI < Grape::API
      namespace :user do
        resources :users do
          
          desc "个人中心"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :personal_center do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              present user, with: ::V1::Entities::User::PersonalCenter
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
          patch :set_head_image do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              picture = Picture.find_or_create_by(imageable: user)
              picture.update!(image: params[:image])
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
