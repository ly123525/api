module V1
  module Entities
    module Mall
      class Channels < Grape::Entity
        expose :image do |m, o|
          m.picture.image.url rescue nil
        end  
        expose :scheme do |m, o|
          "lvsent://gogo.cn/mall/mall_indexs/channels?uuid=#{m.uuid}"
        end  
      end  
    end  
  end  
end  