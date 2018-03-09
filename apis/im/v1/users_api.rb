module V1
  module IM
    class UsersAPI < Grape::API
      namespace :im do
        resources :users do
          desc "获取用户信息"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :im_user_name, type: String, desc: '环信用户名'
          end
          get do
            begin
              authenticate_user
              if params[:im_user_name][0]=="s"
                chat_obj = ::Mall::Shop.where(im_user_name: params[:im_user_name]).first
              else
                chat_obj = ::Account::User.where(im_user_name: params[:im_user_name]).first
              end
              @session_user.add_im_chat_obj(chat_obj)
              { im_nickname: chat_obj.try(:im_nickname), im_image: (chat_obj.picture.image.style_url('120w') rescue nil) }
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "获取用户的聊天列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :chats do
            begin
              authenticate_user
              @session_user.chats.map do |chat|
                {
                  im_nickname: chat.invitee.im_nickname, 
                  im_image: (chat.invitee.picture.image.style_url('120w') rescue nil),
                  im_user_name: chat.invitee.im_user_name
                }
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
