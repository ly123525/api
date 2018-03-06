module V1
  module Mall
    class FightGroupsAPI < Grape::API
      namespace :mall do
        resources :fight_groups do
          desc "拼单成功"
          params do 
            requires :uuid, type: String, desc: '拼单 UUID'
          end      
          get do
            begin
              fight_group = ::Mall::FightGroup.find_uuid(params[:uuid])
              present fight_group, with: ::V1::Entities::Mall::FightGroup
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