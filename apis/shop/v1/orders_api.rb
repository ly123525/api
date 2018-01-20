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
            optional :quantity, type: Integer, default: 1, desc: '数量，默认1'
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
                quantity_str: 'x5',
                quantity: 5,
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
          
          desc "订单列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :page, type: String, default: 1, desc: '页码'
            optional :category, type: String, desc: "按分类查询，默认为全部，{awaiting_payment: '待付款', scrape_together: '拼单中', waiting_for_delivery: '待发货', waiting_for_received: '待收货', waiting_evaluation: '待评价'}"
          end
          get do
            {
              orders: [
                {
                  uuid: '11fewfaef',
                  shop: {
                    name: '店铺名称',
                    logo: 'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1516322006&di=65ee9624697c83b5dcb3292b347d2462&imgtype=jpg&er=1&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01c2ac57beb18d0000012e7eaa6d19.jpg',
                    scheme: 'www.baidu.com',
                  },
                  state: '拼单中',
                  product: {
                    image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
                    title: '恒都 澳洲牛腩块 500克/袋 草饲牛肉 包邮',
                    style_name: '红色 41码',
                    price: '¥ 30.00',
                    quantity_str: 'x5'
                  },
                  pay_amount: '实付 ¥20.00',
                  pay_center_scheme: nil,
                  buy_again_scheme: nil,
                  look_logistics_scheme: nil,
                  to_evaluate_scheme: nil,
                  removeable: true,
                  can_be_hasten: true,
                  confirmable: true,
                  inviting_friends_info: nil
                  # 立即支付
#                   再次购买
#                   查看物流
#                   去评价
#
#                   邀请好友
#                   去催催
#                   确认收货
#                   删除订单
                }
              ]
            }
          end
          
          desc "去催催"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          post :hasten do
            
          end
          
          desc "确认收货"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          patch :confirmed do
            
          end
          
          desc "移除"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '订单 UUID'
          end
          delete do
            
          end
        end
      end
      
    end
  end
end
