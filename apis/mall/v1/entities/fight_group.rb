module V1
  module Entities
    module Mall                  
      class FightGroups < Grape::Entity
        expose :uuid
        expose :nickname do |m, o|
          m.user.nickname
        end
        expose :head_image do |m, o|
          m.user.picture.image.style_url('120w') rescue nil
        end
        expose :remainder do |m, o|
          "还差#{m.residual_quantity}人"
        end
        expose :remaining_time do |m, o|
          (m.expired_at.localtime-Time.now).to_i
        end
        expose :head_images do |m, o|
          m.user_avatars true
        end  
      end 
        
      
      class FightGroup < Grape::Entity
        expose :products, as: :order_items, using: ::V1::Entities::Mall::ProductByOrderItem do |m, o|
          m.order_items_by_user(o[:user])
        end
        expose :style_uuid do |m, o|
          m.style.uuid if m.waiting? && !o[:inner_app] && !m.order_paid_fight_group?(o[:user])
        end  
        expose :title do |m, o|          
          "拼单成功, 商家正在努力发货, 请耐心等待..." if m.completed?
        end          
        expose :tips do |m, o|
          "拼单成功后,拼主获得两张抽奖券,拼客获得一张抽奖券" if m.waiting?
        end
        expose :styles do |m, o|
          m.product.styles_for_choice(m.style.labels) if m.waiting? && !o[:inner_app] && !m.order_paid_fight_group?(o[:user])
        end
        expose :product_uuid do |m, o|
          m.product.uuid if m.waiting? && !o[:inner_app] && !m.order_paid_fight_group?(o[:user])
        end  
        expose :remaining_time do |m, o|
          if  m.waiting?
            (m.expired_at.localtime-Time.now).to_i > 0 ? ((m.expired_at.localtime-Time.now).to_i * 1000) : 0
          end
        end
        expose :residual_quantity do |m, o|          
          m.residual_quantity if m.waiting?
        end
        expose :user_images do |m, o|
          m.user_avatars(false)
        end
        expose :lottery_tips do |m, o|          
          m.fight_group_completed_lottery_tips(o[:user]) if m.completed?
        end     
        expose :inviting_friends_info do |m, o|
          if m.waiting? && m.order_paid_fight_group?(o[:user])
            {
              title: '我在全民拼app买了一件好货，快来加入我的拼单，先到先得',
              image: (m.style.style_cover.image.style_url('300w') rescue nil),
              url: "#{ENV['H5_HOST']}/#/fightgroup?fight_group_uuid=#{m.uuid}",
              summary: ''
            }
          end
        end
        expose :participate_fight_group do |m, o|
           m.waiting? && !o[:inner_app] && !m.order_paid_fight_group?(o[:user])
        end
        expose :lottery_list do |m, o|
          "#{ENV['H5_HOST']}/#/raffletickets" if m.completed?
        end
        expose :to_be_confirmed_scheme do |m, o|
          "#{ENV['H5_HOST']}/#/mall/orders/confirmation" if !o[:inner_app] && !m.order_paid_fight_group?(o[:user]) && m.waiting?
        end        
      end
      
      class FightGroupForOrder < Grape::Entity
        expose :fight_group_remaining_time do |m, o|
          unless m.fight_group.present? && m.fight_group.completed?
            if m.try(:fight_group).try(:expired_at)
              (m.try(:fight_group).try(:expired_at)-Time.now).to_i > 0 ? (m.fight_group.expired_at-Time.now).to_i : 0 
            end  
          end
        end
        expose :fight_group_info do |m, o|
          "等待分享，还差#{m.try(:fight_group).try(:residual_quantity)}人" if m.fight_group.present? && m.fight_group.waiting?             
        end
        expose :user_headers do |m, o|
          m.try(:fight_group).try(:user_avatars, true)
        end
        expose :resource_uuid do |m, o|
          m.uuid
        end
        expose :resource_type do |m, o|
          m.class.to_s
        end 
        expose :share do |m, o|
          {
            title: '我在全民拼app买了一件好货，快来加入我的拼单，先到先得',
            image: (m.order_items.first.style.style_cover.image.style_url('300w') rescue nil),
            url: "#{ENV['H5_HOST']}/#/mall/fightgroup?fight_group_uuid=#{m.fight_group.try(:uuid)}",
            summary: ''
          }
        end       
      end    
    end
  end
end
