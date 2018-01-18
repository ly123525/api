module V1
  module Entities
    module Shop 
      class Products < Grape::Entity
        expose :uuid
        expose :banners do |m, o|
          ['http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021458225.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021533631.jpg', 'http://img.mshishang.com/pics/2015/1118/20151118021535767.jpg']
        end
        expose :title do |m, o|
          '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮'
        end
        expose :slogan do |m, o|
          {content: '特价促销', scheme: 'www.baidu.com'}
        end
        expose :original_price do |m, o|
          "¥ 32.20"
        end
        expose :price do |m, o|
          "¥ 23.20"
        end
        expose :service_note do |m, o|
          [
            {lable: '包邮', desc: '由商家发货，免邮费', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'},
            {lable: '七天无理由退货', desc: '支持7天无理由退货', icon: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg'}
          ]
        end
        expose :sold_count do |m, o|
          '已拼123件 3件起拼'
        end
        expose :promotion_infos do |m, o|
          [
            {lable: "优惠", desc: '使用余额支付，每单减2元', scheme: nil},
            {lable: "双11狂欢节", desc: '全免费', scheme: 'www.baidu.com'}
          ]
        end
        expose :style_name do |m, o|
          "红色 41码"
        end
        expose :max_quantity do |m, o|
          10
        end 
        expose :detail_url do |m, o|
          'www.baidu.com'
        end
        expose :need_to_choose_style do | m, o |
          true
        end
        expose :group_user_size do |m, o|
          "50"
        end
        expose :groups do |m, o|
          [
            {uuid: 'EINGE-ENG93', nickname: '张大拿', remainder: '还差1人', head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg' },
            {uuid: 'EINGE-ENG93', nickname: '张大拿', remainder: '还差1人', head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg' },
            {uuid: 'EINGE-ENG93', nickname: '张大拿', remainder: '还差1人', head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg' },
            {uuid: 'EINGE-ENG93', nickname: '张大拿', remainder: '还差1人', head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg' }
          ]
        end
        expose :comments_count do |m, o|
          "120"
        end
        expose :rate_good do |m, o|
          "100%"
        end
        expose :comments do |m, o|
          [
            {
              uuid: 'ENGNE-ENOGE',
              head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
              nickname: '溜溜',
              style: '规格：400g/袋',
              created_at: '18/01/14',
              content: '好吃的'
            },
            {
              uuid: 'ENGNE-ENOGE',
              head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
              nickname: '溜溜',
              style: '规格：400g/袋',
              created_at: '18/01/14',
              content: '好吃的'
            },
            {
              uuid: 'ENGNE-ENOGE',
              head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
              nickname: '溜溜',
              style: '规格：400g/袋',
              created_at: '18/01/14',
              content: '好吃的'
            },
            {
              uuid: 'ENGNE-ENOGE',
              head_image: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
              nickname: '溜溜',
              style: '规格：400g/袋',
              created_at: '18/01/14',
              content: '好吃的'
            }
          ]
        end
        expose :styles do |m, o|
          [
            {
              category_name: "颜色",
              lables: 
              [
                {lable: "红色", usable: true, selected: true},
                {lable: "蓝色", usable: false, selected: false},
                {lable: "黄色", usable: false, selected: false}
              ]
            },
            {
              category_name: "尺码",
              lables: 
              [
                {lable: "40", usable: false, selected: false},
                {lable: "41", usable: true, selected: true},
                {lable: "42", usable: false, selected: false}
              ]
            }
          ]
        end
        expose :shop do | m, o |
          {
            name: '店铺名称',
            logo: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
            sales_volume: '已拼单：300件',
            product_count: '商品数量：300件',
            scheme: 'www.baidu.com',
          }
        end
        expose :products_for_choice do |m, o|
          {
            category_bar: nil,
            products: 
            [
              {
                image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
                title: '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮',
                original_price: "¥ 32.20",
                price: "¥ 23.20",
                scheme: nil
              },
              {
                image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
                title: '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮',
                original_price: "¥ 32.20",
                price: "¥ 23.20",
                scheme: nil
              },
              {
                image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
                title: '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮',
                original_price: "¥ 32.20",
                price: "¥ 23.20",
                scheme: nil
              }
            ]
          }
        end
        expose :share do 
          expose :url do |m, o|
            
          end
          expose :image do |m, o| 
            
          end
          expose :title do |m, o|
            
          end
          expose :summary do |m, o|
            
          end
        end
      end
    end
  end
end
