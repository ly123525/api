module V1
  module Entities
    module Mall
      class Address < Grape::Entity
        expose :consignee do |m, o|
          "收货人：#{m.name}"
        end
        expose :receiving_address do |m, o|
          "#{m.province} #{m.city} #{m.region} #{m.address}"
        end
      end
      
      class OrderToBeConfirmed < Grape::Entity
        expose :address, using: ::V1::Entities::Mall::Address do |m, o|
          m.user_extra.try(:address)
        end
        expose :address_scheme do |m, o|
          'lvsent://gogo.cn/web?url=' + Base64.urlsafe_encode64('http://39.107.86.17:8080/#/account/addresses')
        end
        expose :shop, using: ::V1::Entities::Mall::SimpleShop do |m, o|
          o[:style].product.shop
        end
        expose :product, using: ::V1::Entities::Mall::ProductForOrder do |m, o|
          o[:style]
        end
        expose :settlement do |m, o|
          m.settlement_info(o[:style], o[:quantity])
        end
      end
    end
  end
end