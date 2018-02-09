module V1
  module Entities
    module Mall
      class Address < Grape::Entity
        expose :consignee do |m, o|
          "收货人：#{m.name}"
        end
        expose :receiving_address do |m, o|
          "#{m.province} #{m.city} #{m.region} #{m.address}"
        end
      end
      
      class OrderToBeConfirmed < Grape::Entity
        expose :address, using: ::V1::Entities::Mall::Address do |m, o|
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
      
      class Orders < Grape::Entity
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
        expose :products, as: :order_items, using: ::V1::Entities::Mall::ProductByOrderItem
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
          m.closed? or m.received? or m.evaluated?
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
    end
  end
end