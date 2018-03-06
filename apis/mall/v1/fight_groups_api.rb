module V1
  module Mall
    class FightGroupsAPI < Grape::API
      
      namespace :mall do
        resources :fight_groups do
          desc "支付成功后，分享页"
          params do
            requires :uuid, type: String, desc: '拼单UUID'
          end
          get :share do
            fight_group = ::Mall::FightGroup.find_uuid(params[:uuid]) rescue nil
            present fight_group, with: ::V1::Entities::Mall::FightGroups
          end 
          
          desc "拼单成功"
          params do 
            requires :uuid, type: String, desc: '拼单UUID'
          end      
          get :success do
            fight_group = ::Mall::FightGroup.find_uuid(params[:uuid]) rescue nil
            present fight_group, with: ::V1::Entities::Mall::SuccessFightGroups
          end  
        end  
      end  
    end  
  end 
end