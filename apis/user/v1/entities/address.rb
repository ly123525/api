module V1
  module Entities
    module User
      class Address < Grape::Entity
        expose :consignee do |m, o|
          m.name
        end
        expose :receiving_address, as: :infos do |m, o|
          m.infos
        end  
      end
      
      class Addresses < Grape::Entity
        expose :uuid
        expose :name
        expose :province
        expose :city
        expose :region
        expose :address
        expose :phone
        expose :is_default
        expose :current_used do |m, o|
          m.user_extra.try(:address_id)==m.id
        end
      end
    end
  end
end
