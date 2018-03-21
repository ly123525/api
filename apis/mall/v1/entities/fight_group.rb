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
          m.expired_at.localtime-Time.now
        end
      end 
        
      
      class FightGroup < Grape::Entity
        expose :status
        with_options(format_with: :timestamp) {expose :updated_at}
        expose :product,  using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          m.style
        end  
        expose :participants, using: ::V1::Entities::User::SimpleUser   
      end
      
      class FightGroupForOrder < Grape::Entity
        expose :pay_remaining_time do |m, o|
          (m.expired_at-Time.now).to_i unless m.fight_group.present? && m.fight_group.completed?
        end
        expose :fight_group_info do |m, o|
          "等待分享，还差#{m.try(:fight_group).try(:residual_quantity)}人" if m.fight_group.present? && m.fight_group.waiting?             
        end
        expose :user_headers do |m, o|
          m.try(:fight_group).try(:user_avatars)
        end
        expose :share do |m, o|
          {
            title: '我在全民拼选购了商品，赶紧来拼单吧',
            image: (m.order_items.first.product.prcture.image.style_url('300w') rescue nil),
            url: 'http://www.baidu.com',
            description: '快来拼单吧'
          }
        end       
      end    
    end
  end
end
