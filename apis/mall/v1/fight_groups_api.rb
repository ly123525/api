module V1
  module Mall
    class FightGroupsAPI < Grape::API
      namespace :mall do
        resources :fight_groups do
          desc "支付成功后,拼单状态展示页"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :uuid, type: String, desc: '拼单 UUID' 
          end
          get  do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              fight_group = ::Mall::FightGroup.find_uuid(params[:uuid])
              fight_group = fight_group.refrensh_status
              inner_app = inner_app? request
              logger.info "=====================拼单状态=============#{fight_group.status}"
              logger.info "=====================订单状态=============#{fight_group.orders.where(user: user).first.try(:status)}"
              present fight_group, with: ::V1::Entities::Mall::FightGroup, user: user, inner_app: inner_app
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