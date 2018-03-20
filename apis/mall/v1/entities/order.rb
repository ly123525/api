module V1
  module Entities
    module Mall
      class OrderToBeConfirmed < Grape::Entity
        expose :address, using: ::V1::Entities::User::Address do |m, o|
          m.user_extra.try(:address)
        end
        expose :address_scheme do |m, o|
          'lvsent://gogo.cn/web?url=' + Base64.urlsafe_encode64('http://39.107.86.17:8080/#/account/addresses')
        end
        expose :shop, using: ::V1::Entities::Mall::SimpleShop do |m, o|
          o[:style].product.shop
        end
        expose :product, using: ::V1::Entities::Mall::ProductForOrder do |m, o|
          o[:style]
        end
        expose :settlement do |m, o|
          ::Mall::Settlement.info(o[:style], o[:quantity], o[:buy_method])
        end
      end
      
      class Order < Grape::Entity
        expose :status do |m, o|
          if m.closed?
            "交易关闭"
          elsif m.created?
            "待支付"
          elsif m.fight_group.present? && m.fight_group.waiting?
            "拼单中..."
          elsif m.paid?
            "等待卖家发货"
          elsif m.delivered?
            "已发货"
          elsif m.received?
            "待评价"
          else
            "已完成"
          end
        end
        expose :pay_remaining_time do |m, o|
          (m.expired_at-Time.now).to_i
        end
        expose :fight_group_residual_quantity do |m, o|
          m.try(:fight_group).try(:residual_quantity) || 0
        end
        expose :user_image do |m, o|
          m.user_avatar
        end
        expose :status
        expose :status_tips do |m, o|
          if m.closed?
            "交易关闭"
          elsif m.fight_group.present? && m.fight_group.waiting?
            "邀请好友拼单"
          elsif m.paid?
            "正在准备货品"
          elsif m.delivered?
            "自发货日起，15日后系统将自动确认收货"
          elsif m.received?
            "客官，给个评价吧~"
          end
        end
        expose :express_company
        expose :express_info do |m, o|
          if m.delivered?
            "点击查看物流信息"
          elsif m.received? or m.evaluated?
            "感谢您在全民拼购物，欢迎您再次光临！"
          end
        end
        expose :express_scheme do |m, o|
          "http://m.kuaidi100.com/index_all.html?type=#{m.express_company_number}&postid=#{m.express_number}"
        end  
        expose :express_at do |m, o|
          if m.delivered?
            Time.now.localtime.strftime('%Y-%m-%d')
          end
        end
        expose :consignee
        expose :mobile
        expose :receiving_address
        expose :im_user_scheme do |m, o|
          "lvsent://gogo.cn/im/chats?im_user_name=#{m.shop.im_user_name}"
        end
        expose :products, as: :order_items, using: ::V1::Entities::Mall::ProductByOrderItem do |m, o|
          m.order_items
        end
        expose :total_fee do |m, o|
          m.total_fee.to_s
        end    
        expose :number
        expose :pay_way do |m, o|
          case m.payment.method
            when 'wechat_pay'
              '微信支付'
            when 'alipay'
              '支付宝'
          end     
        end  
        expose :order_time do |m, o|
         m.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')
        end  
        # expose :im_scheme
      end
      
      class Orders < Grape::Entity
        expose :uuid
        expose :shop, using: ::V1::Entities::Mall::SimpleShop
        expose :status do |m, o|
          if m.closed?
            "交易关闭"
          elsif m.created?
            "待支付" 
          elsif m.fight_group.present? && m.fight_group.waiting?
            "拼单中"
          elsif m.paid?
            "待发货"
          elsif m.delivered?
            "已发货"
          elsif m.received? or m.evaluated?
            "已完成"
          end
        end
        expose :order_items, as: :products, using: ::V1::Entities::Mall::ProductByOrderItem
        expose :pay_amount do |m, o|
          "实付 ¥#{m.total_fee}"
        end
        expose :buy_again_scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.order_items.first.style.uuid}" if m.received? or m.evaluated?
        end
        expose :look_logistics_scheme do |m, o|
          
        end
        expose :to_evaluate_scheme do |m, o|
          'lvsent://gogo.cn/mall/orders/waiting_evaluation' if m.received? and !m.evaluated?
        end
        expose :pay_center_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/payment/modes?order_uuid=#{m.uuid}") if m.created?
        end
        expose :removeable do |m, o|
          m.removeable?
        end
        expose :can_be_hasten do |m, o|
          if m.fight_group.present?
            m.fight_group.completed? && m.paid?
          else
            m.paid?
          end
        end
        expose :confirmable do |m, o|
          m.delivered?
        end
        expose :inviting_friends_info do |m, o|
          if m.fight_group.present? && m.fight_group.waiting?
            image = m.order_items.first.picture.image.style_url('300w') rescue nil
            {
              url: "http://39.107.86.17:8080/#/mall/products?uuid=FEGWGEG",
              image: image,
              title: "来拼",
              summary: "来拼"
            }
          end
        end
      end
      
      class OrderList < Grape::Entity
        expose :orders, using: ::V1::Entities::Mall::Orders
      end
      
      class OrderPayResult < Grape::Entity
        expose :title do |m, o|
          if o[:fight_group]
            "还差#{o[:fight_group].residual_quantity}人，赶快邀请好友拼单吧～"
          end
        end
        expose :desc do |m, o|
          if o[:fight_group]
            "拼单人满后立即发货"
          end
        end
        expose :remaining_time do |m, o|
          o[:fight_group].expired_at.localtime-Time.now
        end
        expose :share do |m, o|
          if o[:fight_group]
            {
              title: '我在全民拼选购了商品，赶紧来拼单吧',
              image: (o[:fight_group].style.prcture.image.style_url('300w') rescue nil),
              url: 'http://www.baidu.com',
              description: '快来拼单吧'
            }
          else
            {
              title: '我在全民拼选购了商品，赶紧来拼单吧',
              image: (m.order_items.first.product.prcture.image.style_url('300w') rescue nil),
              url: 'http://39.107.86.17:8080/#/commdoity',
              description: '快来拼单吧'
            }
          end
        end
      end 
        
    end
  end
end