module V1
  module Entities
    module Mall
      class SectionItems < Grape::Entity
        expose :image do |m, o|
          m.picture.image.style_url('400w') rescue nil
        end  
        expose :scheme
      end  
    end  
  end  
end  
  