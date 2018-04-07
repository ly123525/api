module V1
  module Mall
    class FightGroupsAPI < Grape::API
      namespace :mall do
        resources :fight_groups do
          desc "拼单成功"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌' 
            requires :uuid, type: String, desc: '拼单 UUID'
          end      
          get do
            begin
              logger.info "====================================#{params.to_json}"
              authenticate_user
              fight_group = ::Mall::FightGroup.find_uuid(params[:uuid])
              present fight_group, with: ::V1::Entities::Mall::FightGroup, user: @session_user
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