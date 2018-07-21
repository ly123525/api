module V1
  module Entities
    module Mall
      class LotteryTagsForProduct < Grape::Entity
        expose :activity_image do |m, o|
          m.try(:benz_or_smart_image)
        end
        expose :activity_category do |m, o|
          m.try(:activity_category)
        end
        expose :activity_scheme do |m, o|
          "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/expedite_openaward")
        end
        expose :mini_purchase_quantity do |m, o|
          m.product.mini_purchase_quantity
        end
        expose :master_lottery_quantity do |m, o|
          2 
        end
        expose :guest_lottery_quantity do |m, o|
          1 
        end
      end  
      class VipTagsForProduct < Grape::Entity
        expose :vip_price do |m, o|
          "8.8元" unless  o[:user].try(:is_vip)
        end
        expose :balance do |m, o|
          format('%.2f',m.price.to_s)
        end
        expose :tags do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/product_details_vip_tags.png?x-oss-process=style/160w"
        end
        expose :background do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/product_details_vip_background.png?x-oss-process=style/300w"
        end
        expose :tips_and_scheme do |m, o|
          if o[:user].try(:is_vip)
            {tips: 'VIP社员', scheme: "lvsent://gogo.cn/vip"}
          else
            {tips: '成为VIP社员', scheme: 'lvsent://gogo.cn/vip/right'} 
          end  
        end          
      end
      class WorkScoreTagsForProduct < Grape::Entity
        expose :work_score do |m, o|
          "#{(m.price/2).ceil}工分"  if o[:user].try(:account).try(:work_score).to_f >= (m.price/2).ceil   
        end
        expose :deductible do |m, o|
          "￥" + format('%.2f',(m.price/2).ceil.to_s)
        end
        expose :tags do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/product_details_work_score_tags.png?x-oss-process=style/160w"
        end
        expose :background do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/product_details_work_score_background.png?x-oss-process=style/300w"
        end    
      end    
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
          "¥ " + format('%.2f',m.style.price.to_s)
        end
        expose :original_price do |m, o|
          "¥ " + format('%.2f',m.style.original_price.to_s)
        end
        expose :quantity_str do |m, o|
          "x#{m.quantity}"
        end
        expose :scheme do |m, o|
          if o[:inner_app]
            "lvsent://gogo.cn/mall/products?style_uuid=#{m.style.uuid}"
          else
            "#{ENV['H5_HOST']}/#/mall/details?style_uuid=#{m.style.uuid}"
          end
        end
        expose :activity_image do |m, o|
          m.try(:style).try(:activity_image)
        end
      end

      class SimpleProductByStyle < Grape::Entity
        expose :image do |m, o|
          m.style_cover.image.style_url('480w') rescue nil
        end
        expose :uuid
        expose :title do |m, o|
          m.full_name
        end
        expose :style_name do |m, o|
          m.name
        end
        expose :original_price do |m, o|
          "¥ " + format('%.2f',m.original_price.to_s)
        end
        expose :price do |m, o|
          "¥ " + format('%.2f',m.price.to_s)
        end
        expose :scheme do |m, o|
          if o[:inner_app]
            "lvsent://gogo.cn/mall/products?style_uuid=#{m.uuid}"
          else
            "#{ENV['H5_HOST']}/#/mall/details?style_uuid=#{m.uuid}"
          end
        end
        expose :activity_image do |m, o|
          m.try(:activity_image)
        end
        expose :work_score do |m, o|
          Operate::CommuneHandler.is_operate_style? m
        end
        expose :interesting_currency do |m, o|
          Operate::CommuneHandler.is_operate_style? m
        end
        expose :activity_tags do |m, o|
          m.activity_tags?
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
          o[:style].style_cover.image.style_url('180w') rescue nil
        end
        expose :max_quantity do |m, o|
          100
        end
        expose :sku do |m, o|
          "商品编号：#{o[:style].sku}" rescue nil
        end
        expose :original_price do |m, o|
          "¥ " + format('%.2f',o[:style].original_price.to_s) rescue nil
        end
        expose :price do |m, o|
          "¥ " + format('%.2f',o[:style].price.to_s) rescue nil
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
          if m.product.on_sale?
            unless m.inventory_count.zero?
              "¥ " + format('%.2f',m.original_price.to_s)
            else
              ""
            end
          else
            ""
          end
        end
        expose :price do |m, o|
          if m.product.on_sale?
            unless m.inventory_count.zero?
              "¥ " + format('%.2f',m.price.to_s)
            else
              "已售罄"
            end
          else
            "已下架"
          end
        end
        expose :on_sale do |m,o|
          m.product.on_sale?
        end
        expose :service_note do |m,o|
          m.product.service_note
        end
        expose :sold_count do |m, o|
          "已拼#{m.product.sold_count+m.product.fake_sold_count}件 #{m.product.mini_purchase_quantity}件起拼"
        end
        expose :promotion_infos do |m, o|
          [
            # {label: "优惠", desc: '使用余额支付，每单减2元', scheme: 'www.baidu.com'},
            # {label: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'},
            # {label: "双12狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
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
          # m.product.shop
        end
        expose :products_for_choice, using: ::V1::Entities::Mall::ProductsForChoice do |m, o|
          {category_bar: {image: "#{ENV['IMAGE_DOMAIN']}/app/hot_selling_today.jpg", scheme: ''}, products_by_styles: ::Mall::Style.on_sale_by_product.sorted.limit(4)}
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
            if Operate::CommuneHandler.is_operate_style? m
              "#{ENV['H5_HOST']}/#/mall/details?style_uuid=#{m.uuid}&inviter_uuid=#{o[:user].try(:uuid)}"
            else  
              "#{ENV['H5_HOST']}/#/mall/details?style_uuid=#{m.uuid}"
            end
          end
          expose :image do |m, o|
            m.style_cover.image.style_url('120w')
          end
          expose :title do |m, o|
            m.product.name + " " + m.name
          end
          expose :summary do |m, o|
            m.product.summary_content
          end
        end
        expose :mini_purchase_quantity do |m, o|
          m.product.mini_purchase_quantity
        end
        expose :activity_tags, using: ::V1::Entities::Mall::LotteryTagsForProduct do |m, o|
          m if m.activity_tags?
        end  
        expose :user_is_vip do |m, o|
          o[:user].present? && o[:user].is_vip
        end
        expose :vip_tags, using: ::V1::Entities::Mall::VipTagsForProduct do |m, o|
          m if Operate::CommuneHandler.is_operate_style? m
        end
        expose :work_score_tags, using: ::V1::Entities::Mall::WorkScoreTagsForProduct do |m, o|
          m if Operate::CommuneHandler.is_operate_style? m
        end
        expose :shop_im_chat_scheme do |m, o|
          "lvsent://gogo.cn/im/chats?im_user_name=#{m.product.shop.im_user_name}"
        end    
      end
    end
  end
end
