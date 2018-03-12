module V1
  module Entities
    module Mall
      class Sections < Grape::Entity
        expose :title_bar do |m, o|
          m.picture.image.style_url('400w') rescue nil
        end
        expose :style do |m, o|
          m.type.underscore.split('/').last
        end
        expose :items, using: ::V1::Entities::Mall::SectionItems do |m, o|
          m.section_items
        end  
      end  
    end   
  end  
end  