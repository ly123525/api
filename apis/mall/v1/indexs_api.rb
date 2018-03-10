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
                  {image: 'img.alicdn.com/tfs/TB1qpwlQXXXXXcCXXXXXXXXXXXX-256-256.png_60x60.jpg_.webp', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i3/TB1DGkJJFXXXXaZXFXX07tlTXXX-200-200.png_60x60.jpg_.webp', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i4/TB1zkDeIFXXXXXrXVXX07tlTXXX-200-200.png_60x60.jpg_.webp', scheme: 'www.baidu.com'},
                  {image: 'img.alicdn.com/tps/i2/TB1kUwwIXXXXXXqXpXXUAkPJpXX-87-87.png_60x60.jpg_.webp', scheme: 'www.baidu.com'}
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
                  title_bar: {image: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg', scheme: 'www.baidu.com'},
                  style: 'three_column',
                  items: [ 
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'},
                    {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: 'www.baidu.com'}
                  ]
                },
                {
                  title_bar: {image: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg', scheme: 'www.baidu.com'},
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
              ]
            }          
          end  
        end  
      end  
    end  
  end  
end  