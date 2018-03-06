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
      
      class FightGroup < FightGroups
        expose :status  
      end   
      
      class SuccessFightGroup < Grape::Entity
        expose :avatar do |m, o|
          m.picture.image.style_url('120w') rescue 'http://gogo-bj.oss-cn-beijing.aliyuncs.com/app/head.png?x-oss-process=style/160w'
        end
        expose :updated_at    
        expose :product, using: ::V1::Entities::Mall::SimpleProduct do |m, o|
          o[:product]
        end   
      end
        
    end
  end
end
