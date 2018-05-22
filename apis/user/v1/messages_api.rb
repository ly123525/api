module V1
  module User
    class MessagesAPI < Grape::API
      namespace :user do
        resources :messages do
          
          desc "消息首页"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end  
          get do
            begin
              authenticate_user
              message = @session_user.last_message
              present message, with: ::V1::Entities::User::Message, user: @session_user
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end 
          
          desc "消息已读/未读"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'            
          end
          post do
            begin
              authenticate_user
              message = @session_user.last_message
              ::MessageReadRecord.find_or_create_by_message_and_user message, @session_user
              true
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end                           
          end    
          desc "消息详情列表"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            optional :page, type: Integer, default: 1, desc: '分页页码'           
          end
          get :destail do
            begin
              authenticate_user
              message = @session_user.last_message
              ::MessageReadRecord.find_or_create_by_message_and_user message, @session_user
              messages = @session_user.list_messages.page(params[:page]).per(10)
              present messages, with: ::V1::Entities::User::Messages
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end                          
          end
          
          desc "消息删除"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '消息 UUID'
          end  
          delete do
            begin
              authenticate_user
              message = ::Message.find_uuid(params[:uuid])
              record=::MessageReadRecord.find_or_create_by_message_and_user message, @session_user
              record.update!(deleted: true)
              true
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