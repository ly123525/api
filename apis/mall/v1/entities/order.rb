module V1
  module Entities
    module Mall
      class OrderToBeConfirmed < Grape::Entity
        expose :address, using: ::V1::Entities::User::Address do |m, o|
          m.user_extra.try(:address)
        end
        expose :address_scheme do |m, o|
          'lvsent://gogo.cn/web?url=' + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/account/addresses?from=order")
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
        expose :activity_tags do |m, o|
          o[:style].try(:product).try(:activity_tags)
        end
        expose :activity_image do |m, o|
          o[:style].try(:product).try(:activity_image)
        end
        expose :activity_category do |m, o|
          o[:style].try(:product).try(:activity_category)
        end
      end
      class Express < Grape::Entity
        expose :express_number
        expose :express_company
        expose :express_info do |m, o|
          if m.delivered?
            "点击查看物流信息"
          elsif m.received? or m.evaluated?
            "感谢您在全民拼购物，欢迎您再次光临！"
          end
        end
        expose :express_scheme do |m, o|
           "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://m.kuaidi100.com/index_all.html?type=#{m.express_company_number}&postid=#{m.express_number}")
        end
        expose :express_at do |m, o|
          if m.delivered?
            Time.now.localtime.strftime('%Y-%m-%d')
          end
        end
      end
      class Order < Grape::Entity
        expose :status do |m, o|
          if m.closed?
            "交易关闭"
          elsif m.created?
            "待支付"
          elsif m.fight_group.present? && m.fight_group.waiting?
            "拼单中"
          elsif m.paid_servicing?
            "待发货,售后处理中"
          elsif m.delivered_servicing?
            "待收货,售后处理中"
          elsif m.received_servicing?
            "待评价,售后处理中"
          elsif m.paid?
            "等待卖家发货"
          elsif m.delivered?
            "已发货"
          elsif m.received?
            "待评价"
          elsif m.refunded?
            "已退款"
          else
            "已完成"
          end
        end
        expose :status_tips do |m, o|
          if m.closed?
            "交易关闭"
          elsif m.fight_group.present? && m.fight_group.waiting? && m.paid?
            "邀请好友拼单"
          elsif m.servicing?
            "请前往我的退/换货中查看"
          elsif m.paid?
            "正在准备货品"
          elsif m.delivered?
            "自发货日起，15日后系统将自动确认收货"
          elsif m.received?
            "客官，给个评价吧~"
          end
        end
        expose :status_image do |m, o|
          if m.fight_group.present? && m.fight_group.waiting?
            "#{ENV['IMAGE_DOMAIN']}/app/my_pindan_icon_white.png?x-oss-process=style/120w"
          elsif m.servicing?
            ""
          elsif m.paid?
            "#{ENV['IMAGE_DOMAIN']}/app/my_fahuo_icon_white.png?x-oss-process=style/120w"
          elsif m.delivered?
            "#{ENV['IMAGE_DOMAIN']}/app/my_shouhuo_icon_white.png?x-oss-process=style/120w"
          elsif m.received?
            "#{ENV['IMAGE_DOMAIN']}/app/my_pingjia_icon_white.png?x-oss-process=style/120w"
          elsif m.refunded?
            "#{ENV['IMAGE_DOMAIN']}/app/my_tuihuanhuo_icon_white.png?x-oss-process=style/120w"
          elsif m.created?
            "#{ENV['IMAGE_DOMAIN']}/app/my_tuihuanhuo_icon_white.png?x-oss-process=style/120w"
          end
        end
        expose :service_scheme do |m, o|
          if m.service_details?
            "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/service?uuid=#{m.services.try(:order,'id desc').try(:first).uuid}")
          elsif m.service_express?
            "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services/need_delivery?uuid=#{m.services.try(:order,'id desc').try(:first).uuid}")
          end

        end
        expose :pay_remaining_time do |m, o|
          ((m.expired_at-Time.now).to_i > 0 ? (m.expired_at-Time.now).to_i : 0 ) if m.created?
        end
        expose :fight_group, using: ::V1::Entities::Mall::FightGroupForOrder do |m, o|
          (m.paid? && m.try(:fight_group).try(:waiting?)) ? m : nil
        end
        expose :express, using: ::V1::Entities::Mall::Express do |m, o|
          m unless (m.created? || m.paid? || m.closed? || m.refunded?)
        end
        expose :address do |m, o|
          {
            consignee: m.consignee,
            mobile: m.mobile,
            receiving_address: m.receiving_address
            } if (m.created? || m.paid? || m.closed?)
        end
        expose :im_user_scheme do |m, o|
          "lvsent://gogo.cn/im/chats?im_user_name=#{m.shop.im_user_name}"
        end
        expose :products, as: :order_items, using: ::V1::Entities::Mall::ProductByOrderItem do |m, o|
          m.order_items
        end
        expose :total_fee do |m, o|
          m.total_fee.to_s
        end
        expose :other_infos do |m, o|
          if m.created? || m.closed?
            [
              {title: "订单编号", content: m.number},
              {title: '下单时间', content: m.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')}
            ]
          else
          [
            {title: "订单编号", content: m.number},
            {title: "支付方式", content: m.try(:real_payment).try(:payment_method_name)},
            {title: '下单时间', content: m.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')}
          ]
          end
        end
        expose :buy_again_scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.order_items.first.style.uuid}" if m.received? or m.evaluated?  or m.closed? or m.servicing?
        end
        expose :to_evaluate_scheme do |m, o|
          "lvsent://gogo.cn/mall/orders/evaluate_order?order_item_uuid=#{m.order_items.first.uuid}" if m.received? and !m.evaluated? and !m.received_servicing?
        end
        expose :pay_center_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/cashier?order_uuid=#{m.uuid}") if (m.created? && m.expired_at >= Time.now)
        end
        expose :to_refund_scheme do |m, o|
           "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/services/apply?order_uuid=#{m.uuid}") unless (m.created? || m.closed? || m.servicing? ||m.refunded? || m.fight_group.try(:waiting?) || m.evaluated?)
        end
        expose :can_be_hasten do |m, o|
          if m.fight_group.present?
            m.fight_group.completed? && m.paid? && !m.servicing?
          else
            m.paid? && !m.servicing?
          end
        end
        expose :confirmable do |m, o|
          if m.fight_group.present?
            ((m.delivered? || m.paid?) && m.fight_group.completed? && !m.servicing? )
          else
            (m.delivered? || m.paid?) && !m.servicing?
          end
        end
        expose :inviting_friends_info do |m, o|
          if m.fight_group.present? && m.fight_group.waiting?
            image = m.order_items.first.style.style_cover.image.style_url('300w') rescue nil
            {
              url: "#{ENV['H5_HOST']}/#/fightgroup?uuid=#{m.fight_group.try(:uuid)}",
              image: image,
              title: "我在全民拼app买了一件好货，快来加入我的拼单，先到先得",
              summary: ""
            }
          end
        end
        expose :removeable do |m, o|
          m.removeable?
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
          elsif m.paid_servicing?
            "待发货,售后处理中"
          elsif m.delivered_servicing?
            "待收货,售后处理中"
          elsif m.received_servicing?
            "待评价,售后处理中"
          elsif m.paid?
            "待发货"
          elsif m.delivered?
            "已发货"
          elsif m.received?
            "待评价"
          elsif m.refunded?
            "已退款"
          elsif m.evaluated?
            "已完成"
          end
        end
        expose :order_items, as: :products, using: ::V1::Entities::Mall::ProductByOrderItem
        expose :pay_amount do |m, o|
          "实付 ¥#{m.total_fee}"
        end
        expose :buy_again_scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.try(:order_items).try(:first).try(:style).try(:uuid)}" if m.received? or m.evaluated? or m.closed? or (m.paid? && m.try(:fight_group).try(:completed?) && m.fight_group.present?) or (m.paid? && !m.fight_group.present?) or m.servicing?
        end
        expose :look_logistics_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://m.kuaidi100.com/index_all.html?type=#{m.express_company_number}&postid=#{m.express_number}") if (m.delivered? && !m.servicing?)
        end
        expose :to_evaluate_scheme do |m, o|
          "lvsent://gogo.cn/mall/orders/evaluate_order?order_item_uuid=#{m.order_items.first.uuid}" if m.received? and !m.evaluated? and !m.received_servicing?
        end
        expose :pay_center_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/cashier?order_uuid=#{m.uuid}") if m.created?
        end
        expose :removeable do |m, o|
          m.removeable?
        end
        expose :can_be_hasten do |m, o|
          if m.fight_group.present?
            m.fight_group.completed? && m.paid? && !m.servicing?
          else
            m.paid? && !m.servicing?
          end
        end
        expose :confirmable do |m, o|
          if m.fight_group.present?
            m.delivered? && !m.servicing? && m.fight_group.completed?
          else
            m.delivered? && !m.servicing?
          end
        end
        expose :inviting_friends_info do |m, o|
          if m.fight_group.present? && m.fight_group.waiting? && m.paid?
            image = m.order_items.first.style.style_cover.image.style_url('300w') rescue nil
            {
              url: "#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{m.fight_group.try(:uuid)}",
              image: image,
              title: "我在全民拼app买了一件好货，快来加入我的拼单，先到先得",
              summary: ""
            }
          end
        end
        expose :service_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/service?uuid=#{m.services.try(:order,'id desc').try(:first).uuid}") if m.servicing? || m.refunded?
        end
      end

      class OrderList < Grape::Entity
        expose :orders, using: ::V1::Entities::Mall::Orders
      end
      
      class OrderPayResult < Grape::Entity
        expose :products, as: :order_items, using: ::V1::Entities::Mall::ProductByOrderItem do |m, o|
          m.order_items
        end
        expose :title do |m, o|
          if o[:fight_group].try(:completed?)
            "拼单成功, 商家正在努力发货, 请耐心等待..."
          elsif !o[:fight_group].present?  
            "下单成功, 商家正在努力发货"
          end  
        end          
        expose :tips do |m, o|
          if o[:fight_group].try(:waiting?) && o[:inner_app]
            "拼单人满后立即发货"
          end
        end
        expose :remaining_time do |m, o|
          if  o[:fight_group].try(:waiting?)
            (o[:fight_group].expired_at.localtime-Time.now).to_i > 0 ? ((o[:fight_group].expired_at.localtime-Time.now).to_i * 1000) : 0
          end
        end
        expose :residual_quantity do |m, o|          
          o[:fight_group].residual_quantity if o[:fight_group].try(:waiting?)
        end
        expose :user_images do |m, o|
          o[:fight_group].user_avatars(false) if o[:fight_group]
        end
        expose :lottery_tips do |m, o|          
          m.fight_group_completed_lottery_tips if o[:fight_group].try(:completed?) && o[:fight_group].participants.include?(o[:user]) 
        end     
        expose :inviting_friends_info do |m, o|
          if o[:fight_group].try(:waiting?) && o[:inner_app]
            {
              title: '我在全民拼app买了一件好货，快来加入我的拼单，先到先得',
              image: (o[:fight_group].style.style_cover.image.style_url('300w') rescue nil),
              url: "#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{o[:fight_group].uuid}",
              description: ''
            }
          end
        end
        expose :participate_fight_group do |m, o|
           o[:fight_group].try(:waiting?) && !o[:inner_app] 
        end
        expose :lottery_list do |m, o|
          "#{ENV['H5_HOST']}/#/raffletickets" if o[:fight_group].try(:completed?)
        end
        expose :order_list do |m, o|
          "lvsent://gogo.cn/mall/orders/detail?uuid=#{m.uuid}" unless o[:fight_group]
        end      
      end
    end
  end
end
