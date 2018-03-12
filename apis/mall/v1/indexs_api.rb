module V1
  module Mall
    class IndexsAPI < Grape::API
      namespace :mall do
        resources :indexs do
          desc "商城首页"
          params do 
            
          end  
          get do
            {
              banners: [
                {image: 'https://img.alicdn.com/simba/img/TB1sBZkcf5TBuNjSspcSuvnGFXa.jpg', scheme: 'www.baidu.com'},
                {image: 'https://img.alicdn.com/simba/img/TB1sBZkcf5TBuNjSspcSuvnGFXa.jpg', scheme: 'www.baidu.com'}
              ],
              channel: {
                background: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
                items:[
                  {image: 'img.alicdn.com/tfs/TB1qpwlQXXXXXcCXXXXXXXXXXXX-256-256.png_60x60.jpg', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i3/TB1DGkJJFXXXXaZXFXX07tlTXXX-200-200.png_60x60.jpg', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i4/TB1zkDeIFXXXXXrXVXX07tlTXXX-200-200.png_60x60.jpg', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i2/TB1kUwwIXXXXXXqXpXXUAkPJpXX-87-87.png_60x60.jpg', scheme: 'www.baidu.com'}
                ]
              },
              sections: [
                {
                  title_bar: nil,
                  style: 'three_column',
                  items: [ 
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
                  ]
                },
                {
                  title_bar: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
                  style: 'three_column',
                  items: [ 
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
                  ]
                },
                {
                  title_bar: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
                  style: 'three_column',
                  items: [ 
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
                  ]
                }
              ],
              recommend: {
                title_bar:  'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
                items: [
                  {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: '唯新115g儿童营养猪肉松/肉酥 罐装健康辅食佐餐', price: '￥35.9'},
                  {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: 'Walch/威露士衣物家居消毒液1L+健康抑菌洗手液525ml', price: '￥34.9'},
                  {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: '保税日本 狮王lion CLINICA酵素珍珠美白牙膏百花+鲜果薄荷130g*2', price: '￥55.00'},
                  {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com', title: 'KENZO/高田贤三 童装 男童T恤 Q02747984 BLUE', price: '￥1078'}
                ]
              }
            }          
          end  
        end  
      end  
    end  
  end  
end  