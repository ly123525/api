module V1
  module Entities
    module Mall
      class BrowseRecords < Grape::Entity
        expose :day do |m, o|
          m.created_at.strftime('%m月%d日')
        end   
        expose :title do |m, o|
          m.style.product.name + " " + m.style.name
        end
        expose :image do |m, o|
          m.style.adaption_pictures.sorted.last.image.style_url('180w') rescue nil
        end
        expose :scheme do |m, o|
          "http://39.107.86.17/v1/mall/products?style_uuid=#{m.style.uuid}"
        end
        expose :original_price do |m, o|
          m.style.original_price.to_s
        end
        expose :price do |m, o|
          m.style.price.to_s
        end          
      end  
    end  
  end  
end  