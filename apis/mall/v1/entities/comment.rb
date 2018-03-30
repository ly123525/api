module V1
  module Entities
    module Mall                  
      class Comments < Grape::Entity
        expose :uuid
        expose :nickname do |m, o|
          m.user.nickname
        end
        expose :head_image do |m, o|
          m.user.picture.image.style_url('120w') rescue nil
        end
        expose :style do |m, o|
          "规格：#{m.try(:order_item).try(:product_name)}"
        end
        expose :content
        expose :created_at do |m, o|
          m.created_at.localtime.strftime('%y/%m/%d')
        end
      end
    end
  end
end
