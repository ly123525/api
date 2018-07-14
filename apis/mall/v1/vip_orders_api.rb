module V1
  module Mall
    class VipOrdersAPI < Grape::API
      namespace :mall do
        resources :vip_orders do
          desc "会员权益"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          get do
            begin
              user = ::Account::User.find_uuid params[:user_uuid] rescue nil
              []
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end            
          end    
          desc "会员订单下单"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'            
          end
          post do
            begin
              authenticate_user
              app_error('您已经是VIP', 'You are already VIP') if @session_user.vip_orders.last.paid?
              vip_order = @session_user.vip_orders.create!(total_fee: 8.8, expired_at: ::Mall::VipOrder::EXPIRED_RANGE, number: Time.now.to_i)
              {order_uuid: vip_order.uuid, scheme: 'lvsent://gogo.cn/web?url='+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/cashier?order_uuid=#{vip_order.uuid}")}
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