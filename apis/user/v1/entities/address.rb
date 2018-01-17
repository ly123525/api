module V1
  module Entities
    module User
      class Addresses < Grape::Entity
        expose :uuid
        expose :name
        expose :province
        expose :city
        expose :address 
        expose :mobile 
        expose :is_default
        expose :current_used do |m, o|
          m.user_extra.pluck(:id).present?
        end
      end
    end
  end
end
