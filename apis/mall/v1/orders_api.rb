module V1
  module Mall
    class OrdersAPI < Grape::API
      namespace :mall do
        resources :orders do
          
          desc "待确认"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :buy_method, type: String, default: 'fight_group', desc: '购买方式', values: ['fight_group', 'buy_now']
            requires :style_uuid, type: String, desc: '商品款式 UUID'
            optional :quantity, type: Integer, default: 1, desc: '数量，默认1'
          end
          get :to_be_confirmed do
            begin
              authenticate_user
              style = ::Mall::Style.find_uuid(params[:style_uuid])
              present @session_user, with: ::V1::Entities::Mall::OrderToBeConfirmed, style: style, quantity: params[:quantity], buy_method: params[:buy_method]
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "下单"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :buy_method, type: String, default: 'fight_group', desc: '购买方式', values: ['fight_group', 'buy_now']
            requires :style_uuid, type: String, desc: '商品款式 UUID'
            optional :fight_group_uuid, type: String, desc: '团购分组的 UUID'
            optional :quantity, type: Integer, default: 1, desc: '数量，默认1'
            optional :remark, type: String, desc: '备注'
          end
          post do
            begin
              authenticate_user
              app_error("请选择收货地址", "Please choose the receiving address") if @session_user.user_extra.try(:address).blank?
              style = ::Mall::Style.with_deleted.find_uuid(params[:style_uuid])
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") if style.deleted?
              app_error("该款商品库存不足", "Product style lack of stock") if style.inventory_count.zero?
              order = ::Mall::Order.generate!(params[:buy_method], params[:fight_group_uuid], @session_user, style, params[:quantity], params[:remark])
              {scheme: 'lvsent://gogo.cn/web?url='+Base64.urlsafe_encode64("http://39.107.86.17:8080/#/payment/modes?order_uuid=#{order.uuid}")}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "订单列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            optional :page, type: Integer, default: 1, desc: '页码'
            optional :category, type: String, desc: "按分类查询，默认为全部，{waiting_for_payment: '待付款', fighting: '拼单中', waiting_received: '待收货', waiting_evaluation: '待评价'}"
          end
          get do
            begin
              authenticate_user
              present ({orders: @session_user.orders.sorted.page(params[:page]).per(20)}), with: ::V1::Entities::Mall::OrderList
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "订单详情"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          get :show do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:uuid])
              present order, with: ::V1::Entities::Mall::Order
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "去催催"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          post :hasten do
            
          end
          
          desc "确认收货"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          patch :confirmed do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:uuid])
              if order.paid?
                {msg: '订单未发货，不能确认收货'}
              else
                order.receive!
                {msg: nil}
              end  
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "移除"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          delete do
            begin
              authenticate_user
              order = @session_user.orders.with_deleted.find_uuid(params[:uuid])
              return if order.deleted?
              app_error("该订单暂时不可删除", "Please choose the receiving address") unless order.removeable?
              order.destroy!
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "取消订单"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
            requires :reason, type: String, desc: '取消原因'
          end
          patch :cancel do
            # begin
            # authenticate_user
            #               order = @session_user.orders.find_uuid(params[:uuid])
            #               app_error("该订单无法取消", "Please choose the receiving address") unless order.created?
            #               order.close!
            #               order.update()
            #               nil
            # rescue ActiveRecord::RecordNotFound
            #               app_uuid_error
            #             rescue Exception => ex
            #               server_error(ex)
            #             end
          end
          
          desc "支付成功后，分享页"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌' 
            requires :uuid, type: String, desc: '订单 UUID'
          end
          get :pay_result do
            begin
              authenticate_user
              order = ::Mall::Order.find_uuid(params[:uuid])
              fight_group = order.fight_group
              present :order, with: ::V1::Entities::Mall::OrderPayResult, fight_group: fight_group
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "创建评论页面"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_item_id, type: String, desc: '子订单 uuid' 
          end  
          get :comment do
            begin
              authenticate_user
              order_item = ::Mall::OrderItem.find_uuid(params[:order_item_id])
              {name: order_item.product_name, image: order_item.try(:picture).try(:image).try(:tyle_url,'160w')}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end  
          end
          
          desc "创建评论"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_item_id, type: String, desc: '子订单 uuid' 
            requires :content, type: String, desc: '评论内容'
            requires :level, type: Integer, values: [1, 2, 3], desc: '1: good, 2: medium, 3: bad' 
          end
          post :comment do
            begin
              authenticate_user
              order_item = ::Mall::OrderItem.find_uuid(params[:order_item_id])
              ::Mall::Comment.create!(order_item: order_item, user: @session_user, order: order_item.order, product: order_item.product, content: params[:content], level: params[:level])
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
