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
        expose :activity_tags do |m, o|
          m.try(:product).try(:activity_tags)
        end
        expose :activity_image do |m, o|
          m.try(:product).try(:activity_image)
        end
        expose :activity_category do |m, o|
          m.try(:product).try(:activity_category)
        end
      end

      class SimpleProductByStyle < Grape::Entity
        expose :image do |m, o|
          m.style_cover.image.style_url('480w') rescue nil
        end
        expose :title do |m, o|
          m.full_name
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
        expose :activity_tags do |m, o|
          m.try(:product).try(:activity_tags)
        end
        expose :activity_image do |m, o|
          m.try(:product).try(:activity_image)
        end
        expose :activity_category do |m, o|
          m.try(:product).try(:activity_category)
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
        expose :to_be_confirmed_scheme do |m, o|
          "#{ENV['H5_HOST']}/#/mall/orders/confirmation" unless o[:inner_app]
        end  
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
          o[:style].style_cover.image.style_url('180w') rescue nil
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
          m.full_name
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
        expose :service_note do |m,o|
          m.product.service_note
        end
        expose :sold_count do |m, o|
          "已拼#{m.product.sold_count+m.product.fake_sold_count}件 #{m.product.mini_purchase_quantity}件起拼"
        end
        expose :promotion_infos do |m, o|
          [
            # {label: "优惠", desc: '使用余额支付，每单减2元', scheme: nil},
            # {label: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
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
            "#{ENV['H5_HOST']}/#/mall/products/details?style_uuid=#{m.uuid}"
          end
        end
        expose :need_to_choose_style do | m, o |
          m.product.styles.size!=1
        end
        expose :group_user_size do |m, o|
          m.product.fight_groups.waiting.count
        end
        expose :groups, using: ::V1::Entities::Mall::FightGroups do |m, o|
          m.product.fight_groups.where.not(user: o[:user]).waiting.not_expired.sorted
        end
        # expose :all_groups_scheme do |m, o|
        #    "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/messages/bill?product_uuid=#{m.product.uuid}") unless m.product.fight_groups.where.not(user: o[:user]).waiting.size <= 0
        # end
        expose :comments_count do |m, o|
          m.product.comments.count
        end
        expose :rate_good do |m, o|
          "#{m.product.rate_good}%"
        end
        expose :comments, using: ::V1::Entities::Mall::Comments do |m, o|
          m.product.comments.sorted.limit(4)
        end
        expose :comments_scheme do |m, o|
           "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/mall/commodity/evaluate?style_uuid=#{m.uuid}")
        end
        expose :styles do |m, o|
          m.product.styles_for_choice(m.labels)
        end
        expose :shop, using: ::V1::Entities::Mall::Shop do |m, o|
          m.product.shop
        end
        expose :products_for_choice, using: ::V1::Entities::Mall::ProductsForChoice do |m, o|
          {category_bar: {image: "#{ENV['IMAGE_DOMAIN']}/app/product_recommed.png?x-oss-process=style/400w", scheme: ''}, products_by_styles: ::Mall::Style.recommended.joins(:product).where('mall_products.on_sale is true').sorted.limit(4)}
        end
        expose :collected do |m , o|
          o[:user] && m.collections.where(user: o[:user]).count>0
        end
        expose :resource_uuid do |m, o|
          m.uuid
        end
        expose :resource_type do |m, o|
          m.class.to_s
        end 
        expose :share do
          expose :url do |m, o|
            "#{ENV['H5_HOST']}/#/mall/products?style_uuid=#{m.uuid}"
          end
          expose :image do |m, o|
            m.style_cover.image.style_url('120w')
          end
          expose :title do |m, o|
            m.product.name + " " + m.name
          end
          expose :summary do |m, o|
            ""
          end     
        end
        expose :activity_tags do |m, o|
          m.try(:product).try(:activity_tags)
        end
        expose :activity_image do |m, o|
          m.try(:product).try(:activity_image)
        end
        expose :activity_category do |m, o|
          m.try(:product).try(:activity_category)
        end
        expose :activity_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/expedite_openaward") if m.product.benz_tags? || m.product.smart_tags?
        end
        expose :mini_purchase_quantity do |m, o|
          m.product.mini_purchase_quantity
        end
        expose :activity_lottery_tips do |m, o|
          "拼主获得2张抽奖券,拼客获得1张抽奖券"
        end
      end
    end
  end
end
