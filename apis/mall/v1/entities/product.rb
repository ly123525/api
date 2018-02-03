module V1
  module Entities
    module Mall
      class Products < Grape::Entity
        expose :image do |m, o|
          m.pictures.sorted.last.image.style_url('480w') rescue nil
        end
        expose :title do |m, o|
          m.product.name + " " + m.name
        end
        expose :original_price do |m, o|
          m.original_price
        end
        expose :price do |m, o|
          m.price
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/shop/products?style_uuid=#{m.uuid}"
        end
      end
      
      class ProductsForChoice < Grape::Entity
        expose :category_bar
        expose :products, using: ::V1::Entities::Mall::Products
      end
      
      class Product < Grape::Entity
        expose :uuid do |m, o|
          o[:style].uuid
        end
        expose :banners do |m, o|
          o[:style].pictures.map{|picture| picture.image.style_url('480w') } rescue nil
        end
        expose :title do |m, o|
          m.name + " " + o[:style].name
        end
        expose :slogan do |m, o|
          {content: m.slogan, scheme: nil} if m.slogan.present?
        end
        expose :original_price do |m, o|
          o[:style].original_price
        end
        expose :price do |m, o|
          o[:style].price
        end
        expose :service_note do |m, o|
          [
            {label: '包邮', desc: '由商家发货，免邮费', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'},
            {label: '七天无理由退货', desc: '支持7天无理由退货', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'}
          ]
        end
        expose :sold_count do |m, o|
          "已拼#{m.sold_count+m.fake_sold_count}件 #{m.mini_purchase_quantity}件起拼"
        end
        expose :promotion_infos do |m, o|
          [
            {label: "优惠", desc: '使用余额支付，每单减2元', scheme: nil},
            {label: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
          ]
        end
        expose :style_name do |m, o|
          o[:style].name
        end
        expose :max_quantity do |m, o|
          100
        end 
        expose :detail_url do |m, o|
          if m.details_url.present?
            m.details_url
          else
            "http://39.107.86.17:8080/#/mall/products/details?uuid=#{o[:style].uuid}"
          end
        end
        expose :need_to_choose_style do | m, o |
          m.styles.size!=1
        end
        expose :group_user_size do |m, o|
          m.fighting_orders.size.to_s
        end
        expose :groups, using: ::V1::Entities::Mall::FightGroups do |m, o|
          m.fight_groups.waiting.not_expired.sorted
        end
        expose :comments_count do |m, o|
          m.comments.count
        end
        expose :rate_good do |m, o|
          "#{m.rate_good}%"
        end
        expose :comments, using: ::V1::Entities::Mall::Comments do |m, o|
          m.comments.sorted.limit(4)
        end
        expose :styles do |m, o|
          m.styles_for_choice(o[:style].labels)
        end
        expose :shop, using: ::V1::Entities::Mall::Shop
        expose :products_for_choice, using: ::V1::Entities::Mall::ProductsForChoice
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
