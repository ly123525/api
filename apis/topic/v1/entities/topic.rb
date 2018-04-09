module V1
  module Entities
    module Topic
      class Topic < Grape::Entity
        expose :image do |m, o|
          m.target.adaption_pictures.sorted.last.image.style_url('480w') rescue nil
        end
        expose :title do |m, o|
          m.target.product.name
        end
        expose :style_name do |m, o|
          m.target.name
        end
        expose :original_price do |m, o|
          "¥ " + m.target.original_price.to_s
        end
        expose :price do |m, o|
          "¥ " + m.target.price.to_s
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.target.uuid}"
        end 
      end  
    end  
  end  
end  