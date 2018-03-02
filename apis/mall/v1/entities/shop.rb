module V1
  module Entities
    module Mall   
      class SimpleShop < Grape::Entity
        expose :hx_user_name
        expose :name
        expose :logo do |m, o|
          m.picture.image.style_url('120w') rescue nil
        end
        expose :scheme do |m, o| 
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("http://39.107.86.17:8080/#/mall/shops?uuid=#{m.uuid}")
        end
      end
                    
      class Shop < SimpleShop
        expose :sales_volume do |m, o|
          "已拼单：#{m.winning_orders.count}件"
        end
        expose :product_count do |m, o|
          "商品数量：#{m.products.count}件"
        end
      end
      
      class ShopForService < Grape::Entity
        expose :name
        expose :product, using: ::V1::Entities::Mall::SimpleProduct do |m, o|
          o[:product]
        end
      end
    end
  end
end
