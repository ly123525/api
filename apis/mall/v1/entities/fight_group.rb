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
        expose :status_image do |m, o|
          if m.completed?
            "https://gogo-bj.oss-cn-beijing.aliyuncs.com/app/chenggong3.png?x-oss-process=style/160w"
          end  
        end  
        expose :status do |m, o|
          if m.waiting?
            "还差#{m.residual_quantity}人，赶紧邀请好友拼单吧！"
          elsif m.completed?
            "拼单成功，商家正在努力发货，请耐心等待..."  
          end  
        end  
        with_options(format_with: :timestamp) {expose :updated_at}
        expose :product,  using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          m.style
        end  
        # expose :participants, using: ::V1::Entities::User::SimpleUser
        expose :user_images do |m, o| 
          m.user_avatars
        end
        expose :buy_again_scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.style.uuid}" if m.user == o[:user]
        end
        expose :inviting_friends_info do |m, o|
           if m.waiting? && m.user != o[:user]
             image = m.orders.first.order_items.first.picture.image.style_url('300w') rescue nil
             {
               url: "http://39.107.86.17:8080/#/mall/products?uuid=#{m.product.uuid}",
               image: image,
               title: "来拼",
               summary: "来拼"
             }
           end
         end   
      end
      
      class FightGroupForOrder < Grape::Entity
        expose :fight_group_remaining_time do |m, o|
          unless m.fight_group.present? && m.fight_group.completed?
            if m.try(:fight_group).try(:expired_at)
              (m.try(:fight_group).try(:expired_at)-Time.now).to_i > 0 ? (m.expired_at-Time.now).to_i : 0 
            end  
          end
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
            url: "http://39.107.86.17:8080/#/mall/products?uuid=#{m.order_items.first.product.uuid}",
            summary: '快来拼单吧'
          }
        end       
      end    
    end
  end
end
