module V1
  module Mall
    class OrdersAPI < Grape::API
      namespace :mall do
        resources :orders do
          
          desc "待确认"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :buy_method, type: String, default: 'fight_group', desc: '购买方式', values: ['fight_group', 'buy_now']
            requires :style_uuid, type: String, desc: '商品款式 UUID'
            optional :quantity, type: Integer, default: 1, desc: '数量，默认1'
          end
          get :to_be_confirmed do
            begin
              authenticate_user
              style = ::Mall::Style.find_uuid(params[:style_uuid])
              present @session_user, with: ::V1::Entities::Mall::OrderToBeConfirmed, style: style, quantity: params[:quantity], buy_method: params[:buy_method]
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "公鸡下蛋"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :buy_method, type: String, default: 'fight_group', desc: '购买方式', values: ['fight_group', 'buy_now']
            
            requires :style_uuid, type: String, desc: '商品款式 UUID'
            optional :quantity, type: Integer, default: 1, desc: '数量，默认1'
            optional :remark, type: String, desc: '备注'
          end
          post do
            begin
              authenticate_user
              app_error("请选择收货地址", "Please choose the receiving address") if @session_user.user_extra.try(:address).blank?
              style = ::Mall::Style.with_deleted.find_uuid(params[:style_uuid])
              app_error("该款商品已下架，请选购其它商品", "Product style off the shelf") if style.deleted?
              app_error("该款商品库存不足", "Product style lack of stock") if style.inventory_count.zero?
              order = ::Mall::Order.generate!(params[:buy_method], @session_user, style, params[:quantity], params[:remark])
              {scheme: 'lvsent://gogo.cn/web?url='+Base64.urlsafe_encode64("http://39.107.86.17:8080/#/payment/modes?order_uuid=#{order.uuid}")}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
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
