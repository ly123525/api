module V1
  module Entities
    module Mall
      class Channels < Grape::Entity
        expose :image do |m, o|
          m.picture.image.style_url('300w') rescue nil
        end  
        expose :scheme
      end  
    end  
  end  
end  