module V1
  module Mall
    class FightGroupsAPI < Grape::API
      
      namespace :mall do
        resources :fight_groups do
          desc "拼单成功"
          params do 
            requires :uuid, type: String, desc: '拼单UUID'
          end      
          get :success do
            fight_group = ::Mall::FightGroup.find_uuid(params[:uuid]) rescue nil
            product = fight_group.product
            present fight_group, with: ::V1::Entities::Mall::SuccessFightGroup, fight_group: fight_group
          end  
        end  
      end  
    end  
  end 
end