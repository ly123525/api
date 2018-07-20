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
              {
                button_tips: '支付8.8元, 成为VIP社员',
                images:                 
                [
                  {image: "#{ENV['IMAGE_DOMAIN']}/app/vip_full_return.png", tips: '全额返'},
                  {image: "#{ENV['IMAGE_DOMAIN']}/app/vip_work_score.png", tips: '工分'},
                  {image: "#{ENV['IMAGE_DOMAIN']}/app/vip_vip.png", tips: '社员专享'},
                  {image: "#{ENV['IMAGE_DOMAIN']}/app/vip_cooperation.png", tips: '互助惠'},
                  {image: "#{ENV['IMAGE_DOMAIN']}/app/vip_service.png", tips: '专属客服'}
                ]
              }
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
              app_error('您已经是VIP', 'You are already VIP') if @session_user.is_vip?
              vip_order = @session_user.vip_orders.create!(total_fee: @session_user.is_developer? ? 0.1 : 8.8, 
                expired_at: Time.now + ::Mall::VipOrder::EXPIRED_RANGE, 
                number: Time.now.to_i)
              {order_uuid: vip_order.uuid, scheme: 'lvsent://gogo.cn/web?url='+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/cashier?order_uuid=#{vip_order.uuid}&order_type=#{::Payment::ORDER_TYPE_VIP}")}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          desc "会员支付成功"
          params do 
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          get :pay_result do
            begin
              authenticate_user
              order = ::Mall::VipOrder.find_uuid params[:uuid]
              order.refrensh_status
              inner_app = inner_app? request
              present order, with: ::V1::Entities::Mall::PayResult, inner_app: inner_app
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