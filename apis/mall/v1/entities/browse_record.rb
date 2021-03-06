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
          m.style.style_cover.image.style_url('180w') rescue nil
        end
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/products?style_uuid=#{m.style.uuid}"
        end
        expose :original_price do |m, o|
          format('%.2f',m.style.original_price.to_s)
        end
        expose :price do |m, o|
          format('%.2f',m.style.price.to_s)
        end
        expose :activity_image do |m, o|
          ::Operate::LotteryHandler.activity_image(m.style)
        end         
      end
    end
  end
end
