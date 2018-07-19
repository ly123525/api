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
            optional :payment_method, type: String, default: 'cash', values: ['cash', 'balance', 'work_score'], desc: '支付方式'
          end
          get :to_be_confirmed do
            begin
              authenticate_user
              style = ::Mall::Style.find_uuid(params[:style_uuid])
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") if style.deleted?
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") unless style.product.on_sale
              app_error("该款商品库存不足", "Product style lack of stock") if style.inventory_count.zero?
              inner_app = inner_app? request
              present @session_user, with: ::V1::Entities::Mall::OrderToBeConfirmed, style: style, quantity: params[:quantity], buy_method: params[:buy_method], inner_app: inner_app, payment_method: params[:payment_method]
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
            optional :deduction_method, type: String, values: ['balance', 'work_score'], desc: '抵扣方式, balance: 趣币, work_score: 工分'
            optional :deduction_method_fee, type: BigDecimal, desc: '抵扣方式的金额'
          end
          post do
            begin
              authenticate_user
              app_error("您已经参与过此次拼单", "You have already participated this fight group") if @session_user.participate_fight_group? params[:fight_group_uuid]
              app_error("请选择收货地址", "Please choose the receiving address") if @session_user.user_extra.try(:address).blank?
              app_error("趣币不足","Lack of interest currency") if params[:deduction_method] == 'balance' && (@session_user.account.present? &&  @session_user.account.balance < params[:deduction_method_fee] || @session_user.account.blank?)
              app_error("工分不足","Lack of work score") if params[:deduction_method] == 'work_score' && (@session_user.account.present? &&  @session_user.account.work_score < params[:deduction_method_fee] || @session_user.account.blank?)
              style = ::Mall::Style.with_deleted.find_uuid(params[:style_uuid])
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") if style.deleted?
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") unless style.product.on_sale
              app_error("该款商品库存不足", "Product style lack of stock") if style.inventory_count.zero?
              order = ::Mall::Order.generate!(params[:buy_method], params[:fight_group_uuid], @session_user, style, params[:quantity], params[:remark], params[:deduction_method], params[:deduction_method_fee])
              inner_app = inner_app? request
              scheme = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{order.fight_group.uuid}")  if order.total_fee.zero? && params[:buy_method] == 'fight_group' && inner_app
              scheme = "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/maverick/buying/success?uuid=#{order.uuid}")  if order.total_fee.zero? && params[:buy_method] == 'buy_now' && inner_app
              scheme = "#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{order.fight_group.uuid}" if order.total_fee.zero? && params[:buy_method] == 'fight_group' && !inner_app
              scheme = "#{ENV['H5_HOST']}/#/maverick/buying/success?uuid=#{order.uuid}" if order.total_fee.zero? && params[:buy_method] == 'buy_now' && !inner_app
              scheme = 'lvsent://gogo.cn/web?url='+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/cashier?order_uuid=#{order.uuid}&order_type=#{::Payment::ORDER_TYPE_PRODUCT}") if order.total_fee > 0  
              {order_uuid: order.uuid, scheme: scheme, total_fee: order.total_fee.to_f }
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
              orders = ::Mall::Order.list_orders(params[:category], @session_user).sorted.page(params[:page]).per(10)
              ::Mall::Order.refrensh_status(orders)
              ::Mall::Order.auto_fight_group_list(orders)
              inner_app = inner_app? request
              present ({orders: orders}), with: ::V1::Entities::Mall::OrderList, inner_app: inner_app
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
              order.refrensh_status
              order.auto_fight_group
              inner_app = inner_app? request
              present order, with: ::V1::Entities::Mall::Order, inner_app: inner_app
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
            {tips: '已经催过了，卖家会尽快发货'}
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
              app_error("订单未发货，不能确认收货", "The order is not delivered, and the goods cannot be confirmed") if order.paid?
              order.receive!
              nil
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
              return true if order.deleted?
              app_error("该订单暂时不可删除", "Please choose the receiving address") unless order.removeable?
              order.destroy!
              @session_user.user_messages.where("scheme like ?", "%#{order.uuid}%").each do |message|
                message.message_read_records.delete_all if message.message_read_records.present?
                message.destroy
              end  
              true
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
          desc "支付成功后的展示页,单独购买"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          get :pay_result do
            begin
              authenticate_user
              order = ::Mall::Order.find_uuid params[:uuid]
              order.refrensh_status
              inner_app = inner_app? request
              present order, with: ::V1::Entities::Mall::OrderPayResult, inner_app: inner_app
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
            requires :order_item_uuid, type: String, desc: '子订单 uuid' 
          end  
          get :comment do
            begin
              authenticate_user
              order_item = ::Mall::OrderItem.find_uuid(params[:order_item_uuid])
              {style_name: order_item.product_name, image: order_item.try(:picture).try(:image).try(:style_url,'160w')}
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
            requires :order_item_uuid, type: String, desc: '子订单 uuid' 
            requires :content, type: String, desc: '评论内容'
            requires :level, type: Integer, values: [1, 2, 3], default: 1 ,desc: '1: good, 2: medium, 3: bad' 
          end
          post :comment do
            begin
              app_error("评论内容不能为空", "Comments cannot be empty") if params[:content].blank?
              authenticate_user
              order_item = ::Mall::OrderItem.find_uuid(params[:order_item_uuid])
              app_error("评论不能为空", "Comments cannot be empty") if !params[:content].present?
              app_error("评论字数不能少于6个字符,最多不能超过250个字符", "The number of comments should not be less than 6 characters, not more than 250 characters") if params[:content].size < 6 || params[:content].size >250
              comment=::Mall::Comment.create!(order_item: order_item, user: @session_user, order: order_item.order, product: order_item.product, content: params[:content], level: params[:level])
              comment.order.evaluate! if comment.order.received?  
              nil
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
