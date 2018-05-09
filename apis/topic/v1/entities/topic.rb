module V1
  module Entities
    module Topic
      class Topic < Grape::Entity
        expose :title do |m, o|
          m.title
        end
        expose :products, using: ::V1::Entities::Mall::SimpleProductByStyle do |m, o|
          o[:styles]
        end    
      end    
    end  
  end  
end  