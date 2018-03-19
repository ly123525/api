module V1
  module Entities
    module Mall
      class Recommend < Grape::Entity
        expose :items, using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          o[:styles] || m
        end
      end
      
      class RecommendOfIndex < Recommend
        expose :title_bar do |m, o|
          {
            image: nil,
            scheme: nil
          }
        end
      end  
      
      class MallIndex < Grape::Entity
        expose :search_key do |m, o|
          "搜索结果"
        end  
        expose :banners, using: ::V1::Entities::Mall::Banners do |m, o|
          m.banners
        end
        expose :channels do
          expose :background do |m, o|
            m.channel_background.style_url('400w') rescue nil 
          end  
          expose :items, using: ::V1::Entities::Mall::Channels do |m, o|
            m.channels
          end
        end  
        expose :sections, using: ::V1::Entities::Mall::Sections do |m, o|
          m.sections
        end  
        expose :recommend, using: ::V1::Entities::Mall::RecommendOfIndex do |m, o|
          {title_bar: nil, styles: o[:styles]}
        end  
      end
    end  
  end  
end  
  