module V1
  module Entities
    module Mall
      class BrowseRecords < Grape::Entity
        expose :day do |m, o|
          m.browse_time
        end  
        expose :title do |m, o|
          m.product.name
        end
        expose :image do |m, o|
          m.styles.first.pictures.sorted.last.image.style_url('180w') rescue nil
        end
        expose :scheme do |m, o|
          "http://39.107.86.17/v1/mall/products?uuid=#{m.product.uuid}"
        end
        expose :original_price do |m, o|
          m.product.styles.first.original_price.to_s
        end
        expose :price do |m, o|
          m.product.styles.first.price.to_s
        end          
      end  
    end  
  end  
end  