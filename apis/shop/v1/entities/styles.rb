module V1
  module Entities
    module Shop                  
      class Lable < Grape::Entity
        expose :lable
        expose :usable
        expose :selected
      end
                  
      class Style < Grape::Entity
        expose :category_name
        expose :lables, using: V1::Entities::Shop::Lable
      end
    end
  end
end
