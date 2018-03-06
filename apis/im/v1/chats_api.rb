module V1
  module IM
    class UsersAPI < Grape::API
      namespace :im do
        resources :users do
          desc "通过环信用户名，获取用户信息"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :im_user_name, type: String, desc: '环信用户名'
          end
          get do
            begin
              authenticate_user
              if params[:im_user_name][0]=="s"
                shop = ::Mall::Shop.where(im_user_name: params[:im_user_name]).first
                { nickname: shop.try(:name), image: (shop.picture.image.style_url('120w') rescue nil) }
              else
                user = ::Account::User.where(im_user_name: params[:im_user_name]).first
                { nickname: user.try(:nickname), image: (user.picture.image.style_url('120w') rescue nil) }
              end
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
      end
      
    end
  end
end
