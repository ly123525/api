module V1
  module Entities
    class Categories < Grape::Entity
      expose :name
      expose :uuid
      expose :scheme do |m, o|
        "lvsent://gogo.cn/mall/products/classify_search?uuid=#{m.uuid}&name=#{m.name}" if m.leaves.count.zero?
      end
      expose :image do |m, o|
        m.picture.image.style_url('160w') rescue nil
      end
      expose :children, using: ::V1::Entities::Categories
    end
  end
end