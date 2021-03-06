module V1
  module Entities
    module Mall
      class Recommend < Grape::Entity
        expose :title_bar do |m, o|
          {
            image: "#{ENV['IMAGE_DOMAIN']}/app/hot_selling_today.jpg",
            scheme: nil
          }
        end
        expose :items, using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          o[:styles]
        end
      end

      class MallIndex < Grape::Entity
        expose :pop_up_url do |m, o|
          "#{ENV['H5_HOST']}/#/activity/popup"
        end
        expose :pop_up_image do |m, o|
          "#{ENV['IMAGE_DOMAIN']}/app/index_popwin.png?x-oss-process=style/400w"
        end
        expose :pop_up_scheme do |m, o|
          "lvsent://gogo.cn/web?url="+Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/expedite_openaward")
        end
        expose :search_key do |m, o|
          "搜索结果"
        end
        expose :banners, using: ::V1::Entities::Mall::Banners
        expose :channels do |m, o|
          # expose :background do |m, o|
          #   m.channel_background.style_url('400w') rescue nil
          # end
          # expose :items, using: ::V1::Entities::Mall::Channels do |m, o|
          #   m.channels
          # end
        end
        expose :sections, using: ::V1::Entities::Mall::Sections
        expose :recommend, using: ::V1::Entities::Mall::Recommend do |m, o|
          {title_bar: nil, styles: o[:styles]}
        end
      end
    end
  end
end
