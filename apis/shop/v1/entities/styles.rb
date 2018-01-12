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

      class SelectedStyle < Grape::Entity
        expose :uuid do | m, o |
          "ENOIGNE-UEIONGE"
        end
        expose :name do | m, o |
          "已选: 感应20米"
        end
        expose :image do | m, o |
          'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg'
        end
        expose :images do | m, o |
          ['http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021458225.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021533631.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021535767.jpg']
        end
        expose :inventory do | m, o |
          "库存: 12件"
        end
        expose :inventory_count do |m, o|
          12
        end
        expose :original_price do |m, o|
          "¥ 50.20"
        end
        expose :price do | m, o |
          "¥ 32.20"
        end
        expose :promotion_infos do |m, o|
          [
            {lable: "优惠", desc: '使用余额支付，每单减2元', scheme: nil},
            {lable: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
          ]
        end
      end
    end
  end
end
