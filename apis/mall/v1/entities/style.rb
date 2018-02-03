module V1
  module Entities
    module Mall                  
      class Lable < Grape::Entity
        expose :label
        expose :usable
        expose :selected
      end
                  
      class Style < Grape::Entity
        expose :category_name
        expose :labels, using: V1::Entities::Mall::Lable
      end
    end
  end
end
