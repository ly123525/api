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
        
    end
  end
end
