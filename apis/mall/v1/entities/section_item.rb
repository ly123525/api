module V1
  module Entities
    module Mall
      class SectionItems < Grape::Entity
        expose :image do |m, o|
          m.picture.image.style_url('400w') rescue nil
        end  
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/mall_indexs/section_items?uuid=#{m.uuid}"
        end
      end  
    end  
  end  
end  
  