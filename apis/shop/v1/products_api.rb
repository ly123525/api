module V1
  module Shop
    class ProductsAPI < Grape::API
      namespace :shop do
        resources :products do
          
          desc "商品详情"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
            requires :style_uuid, type: String, desc: '商品款式 UUID'
          end
          get do
            present ::Account::User.first, with: ::V1::Entities::Shop::Products
          end
          
          desc "选择款式"
          params do
            optional :user_uuid, type: String, desc: "用户 UUID"
            requires :style_uuid, type: String, desc: "商品款式 UUID"
            optional :lables, type: Array[String], desc: "url 参数：lables[]=红色&lables[]=41码"
          end
          get :style do
            {
              uuid: "ENOIGNE-UEIONGE",
              image: 'http://img.mshishang.com/pics/2015/1118/20151118021532201.jpg',
              max_quantity: 10, 
              sku: '商品编号：5245',
              original_price: "¥ 50.20",
              price: "¥ 32.20",
              purchasable: true
            }
          end
        end
      end
      
    end
  end
end
