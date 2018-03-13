module V1
  module Mall
    class IndexsAPI < Grape::API
      namespace :mall do
        resources :indexs do
          desc "商城首页"
          params do 
            optional :user_uuid, type: String, desc: '用户UUID'
          end  
          get do
            begin 
              user = ::Account::User.find_uuid(params[:user_uuid]) rescue nil
              app_version_code=app_version_code(request).to_i
              mall_index = ::Mall::Indices::Index.where("version_code > ? ", app_version_code).last || ::Mall::Indices::Index.where("version_code <= ? ", app_version_code).first
              styles = ::Mall::Style.recommended
              present mall_index, with: ::V1::Entities::Mall::MallIndex, styles: styles
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end  
            # {
            #   banners: [
            #     {image: 'https://img.alicdn.com/simba/img/TB1sBZkcf5TBuNjSspcSuvnGFXa.jpg', scheme: 'www.baidu.com'},
            #     {image: 'https://img.alicdn.com/simba/img/TB1sBZkcf5TBuNjSspcSuvnGFXa.jpg', scheme: 'www.baidu.com'}
            #   ],
            #   channel: {
            #     background: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
            #     items:[
            #       {image: 'http://img2.ooopic.com/15/32/92/50bOOOPIC5d_202.jpg', scheme: 'www.baidu.com'},
            #       {image: 'http://www.logobiaozhi.com/images/image/20160824175775627562.jpg', scheme: 'www.baidu.com'},
            #       {image: 'http://file01.16sucai.com/d/file/2014/0323/fbd999ca47188dd5d48c95c0cc965c81.png', scheme: 'www.baidu.com'},
            #       {image: 'http://logo.chuangyimao.com/uploads/logo/20141226/141226094717cbe254e7b2.png', scheme: 'www.baidu.com'}
            #     ]
            #   },
            #   sections: [
            #     {
            #       title_bar: nil,
            #       style: 'three_column',
            #       items: [
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
            #       ]
            #     },
            #     {
            #       title_bar: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
            #       style: 'three_column',
            #       items: [
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
            #       ]
            #     },
            #     {
            #       title_bar: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
            #       style: 'three_column',
            #       items: [
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
            #         {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
            #       ]
            #     }
            #   ],
            #   recommend: {
            #     title_bar:  'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
            #     items: [
            #       {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: '唯新115g儿童营养猪肉松/肉酥 罐装健康辅食佐餐', price: '￥35.9'},
            #       {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: 'Walch/威露士衣物家居消毒液1L+健康抑菌洗手液525ml', price: '￥34.9'},
            #       {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: '保税日本 狮王lion CLINICA酵素珍珠美白牙膏百花+鲜果薄荷130g*2', price: '￥55.00'},
            #       {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: 'KENZO/高田贤三 童装 男童T恤 Q02747984 BLUE', price: '￥1078'},
            #     ]
            #   }
            # }  
          end  
        end  
      end  
    end  
  end  
end  