module V1
  module Entities
    module Mall
      class MallIndex < Grape::Entity
        expose :banners, using: ::V1::Entities::Mall::Banners do |m, o|
          m.banners
        end
        expose :channels, using: ::V1::Entities::Mall::Channels do |m, o|
          m.channels
        end
        expose :sections, using: ::V1::Entities::Mall::Sections do |m, o|
          m.sections
        end
        expose :recommend, using: ::V1::Entities::Mall::ProductsForMallIndex do |m, o|
          o[:products]
        end  
      end
    end  
  end  
end  
  