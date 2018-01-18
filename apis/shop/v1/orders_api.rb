module V1
  module Shop
    class OrdersAPI < Grape::API
      namespace :shop do
        resources :orders do
          
          desc "待确认"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get :to_be_confirmed do
            {
              address: {
                consignee: '收货人：LI',
                receiving_address: '北京市 通州区 通州北苑'
              },
              shop: {
                name: '店铺名称',
                logo: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
                scheme: 'www.baidu.com',
              },
              product: {
                image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
                title: '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮',
                style_name: '红色 41码',
                price: '¥ 30.00',
                quantity: 'x5',
                max_quantity: 20
              },
              # coupon: 
              settlement: {
                infos: [
                  {lable: '商品金额', desc: '¥150.00'},
                  {lable: '优惠', desc: '- ¥20.00'},
                  {lable: '运费', desc: '+ ¥5.00'}
                ],
                pay_amount: '¥20.00',
                pay_scheme: 'www.baidu.com',
              }
            }
          end
        end
      end
      
    end
  end
end
