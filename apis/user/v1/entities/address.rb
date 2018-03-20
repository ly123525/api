module V1
  module Entities
    module User
      class Address < Grape::Entity
        expose :consignee do |m, o|
          m.name
        end
        expose :receiving_address, as: :infos
      end
      
      class Addresses < Grape::Entity
        expose :uuid
        expose :name
        expose :province
        expose :city
        expose :address
        expose :mobile 
        expose :is_default
        expose :current_used do |m, o|
          m.user_extra.present?
        end
      end
    end
  end
end
