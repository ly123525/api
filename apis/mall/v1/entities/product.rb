module V1
  module Entities
    module Mall
      class ProductByOrderItem < Grape::Entity
        expose :image do |m, o|
          m.picture.image.style_url('160w') rescue nil
        end
        expose :title do |m, o|
          m.product_name
        end
        expose :style_name do |m, o|
          m.style_name
        end
        expose :price do |m, o|
          "¥ " + m.style.price.to_s
        end
        expose :quantity_str do |m, o|
          "x#{m.quantity}"
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.style.uuid}"
        end
      end
            
      class SimpleProductByStyle < Grape::Entity
        expose :image do |m, o|
          m.adaption_pictures.sorted.last.image.style_url('480w') rescue nil
        end
        expose :title do |m, o|
          m.product.name
        end
        expose :style_name do |m, o|
          m.name
        end
        expose :original_price do |m, o|
          "¥ " + m.original_price.to_s
        end
        expose :price do |m, o|
          "¥ " + m.price.to_s
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.uuid}"
        end
      end
      
      class ProductsByStyles < SimpleProductByStyle
        expose :black_label do |m, o|
          "已失效" if m.deleted?
        end
      end
      
      class ProductsForChoice < Grape::Entity
        expose :category_bar
        expose :products_by_styles, as: :products, using: ::V1::Entities::Mall::ProductsByStyles
      end
      
      class ProductForOrder < SimpleProductByStyle
        expose :quantity_str do |m, o|
          "x" + o[:quantity].to_s
        end
        expose :quantity do |m, o|
          o[:quantity]
        end
        expose :max_quantity do |m, o|
          100
        end
      end
      
      class ProductForChoice < Grape::Entity
        expose :style_uuid do |m, o|
          o[:style].uuid rescue nil
        end
        expose :image do |m, o|
          o[:style].pictures.sorted.last.image.style_url('180w') rescue nil
        end
        expose :max_quantity do |m, o|
          100
        end
        expose :sku do |m, o|
          "商品编号：#{o[:style].sku}" rescue nil
        end
        expose :original_price do |m, o|
          "¥ " + o[:style].original_price.to_s rescue nil
        end
        expose :price do |m, o|
          "¥ " + o[:style].price.to_s rescue nil
        end
        expose :style_name do |m, o|
          o[:style].name rescue nil
        end
        expose :styles do |m, o|
          o[:styles_for_choice]
        end
      end
      
      class ProductByStyle < Grape::Entity
        expose :uuid do |m, o|
          m.product.uuid
        end
        expose :style_uuid do |m, o|
          m.uuid
        end
        expose :banners do |m, o|
          m.adaption_pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
        expose :title do |m, o|
          m.product.name + " " + m.name
        end
        expose :slogan do |m, o|
          {content: m.product.slogan, scheme: nil} if m.product.slogan.present?
        end
        expose :original_price do |m, o|
          "¥ " + m.original_price.to_s
        end
        expose :price do |m, o|
          "¥ " + m.price.to_s
        end
        expose :service_note do |m, o|
          [
            {label: '包邮', desc: '由商家发货，免邮费', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'},
            {label: '七天无理由退货', desc: '支持7天无理由退货', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'}
          ]
        end
        expose :sold_count do |m, o|
          "已拼#{m.product.sold_count+m.product.fake_sold_count}件 #{m.product.mini_purchase_quantity}件起拼"
        end
        expose :promotion_infos do |m, o|
          [
            {label: "优惠", desc: '使用余额支付，每单减2元', scheme: nil},
            {label: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
          ]
        end
        expose :sku do |m, o|
          "商品编号：#{m.sku}"
        end
        expose :style_name do |m, o|
          m.name
        end
        expose :max_quantity do |m, o|
          100
        end 
        expose :detail_url do |m, o|
          if m.product.details_url.present?
            m.product.details_url
          else
            "http://39.107.86.17:8080/#/mall/products/details?style_uuid=#{m.uuid}"
          end
        end
        expose :need_to_choose_style do | m, o |
          m.product.styles.size!=1
        end
        expose :group_user_size do |m, o|
          m.product.fighting_orders.size.to_s
        end
        expose :groups, using: ::V1::Entities::Mall::FightGroups do |m, o|
          m.product.fight_groups.waiting.not_expired.sorted
        end
        expose :comments_count do |m, o|
          m.product.comments.count
        end
        expose :rate_good do |m, o|
          "#{m.product.rate_good}%"
        end
        expose :comments, using: ::V1::Entities::Mall::Comments do |m, o|
          m.product.comments.sorted.limit(4)
        end
        expose :styles do |m, o|
          m.product.styles_for_choice(m.labels)
        end
        expose :shop, using: ::V1::Entities::Mall::Shop do |m, o|
          m.product.shop
        end
        expose :products_for_choice, using: ::V1::Entities::Mall::ProductsForChoice do |m, o|
          {category_bar: nil, products_by_styles: ::Mall::Style.recommended.sorted.limit(10)}
        end
        expose :collected do |m , o|
          o[:user] && m.collections.where(user: o[:user]).count>0
        end
        expose :share do 
          expose :url do |m, o|
            
          end
          expose :image do |m, o| 
            
          end
          expose :title do |m, o|
            
          end
          expose :summary do |m, o|
            
          end
        end
      end
    end
  end
end
