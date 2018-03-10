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
                sections: [
                  { style: 'small_one',
                    items: [ 
                             {image: 'https://img.alicdn.com/simba/img/TB1A4yuXTXYBeNkHFrdSuwiuVXa.jpg', scheme: nil },
                             {image: 'https://img.alicdn.com/simba/img/TB1Ao3XaL5TBuNjSspcSuvnGFXa.jpg', scheme: nil } 
                           ]
                  },
                  {
                    style: 'large_top',
                    items: [
                            {image: 'img.alicdn.com/tfs/TB16HWinBTH8KJjy0FiXXcRsXXa-520-280.jpg_q90_.webp', scheme: nil, title: '恒都 澳洲牛肉腩块 500克/一袋 草饲牛肉 包邮', price: '￥27.8'},
                            {image: 'https://img.alicdn.com/simba/img/TB1M3Jrmkfb_uJjSsrbSuv6bVXa.jpg', scheme: nil, title: '恒都 澳洲牛肉腩块 600克/一袋 草饲牛肉 包邮', price: '￥28.8'}
                            ]
                  },
                  {
                    section_bars: [{image: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg', scheme: nil}],
                    style: 'four_small_two',
                    items: [
                            {image: 'http://img.alicdn.com/imgextra/i4/2976970074/TB2rj8Igj3z9KJjy0FmXXXiwXXa_!!2976970074-0-beehive-scenes.jpg_360x360xzq90.jpg_.webp', title: 'asdfgghhh', price: '￥100', scheme: nil},
                            {image: 'img.alicdn.com/imgextra/i1/2201749352/TB2s0ecksnI8KJjSsziXXb8QpXa_!!2201749352-2-beehive-scenes.png_360x360xzq90.jpg_.webp', title: 'fdfdf', price: '￥90', scheme: nil},
                            {image: 'img.alicdn.com/imgextra/i3/868419622/TB2SRxKf_vI8KJjSspjXXcgjXXa_!!868419622-0-daren.jpg_360x360xzq90.jpg_.webp', title: '啊啊啊啊啊啊', price: '￥80', scheme: nil},
                            {image: 'img.alicdn.com/imgextra/i1/2322059577/TB29iFghsjI8KJjSsppXXXbyVXa_!!2322059577-0-beehive-scenes.jpg_360x360xzq90.jpg_.webp', title: '撒啊啊', price: '￥99', scheme: nil}
                    ]
                  },
                  {
                    style: 'small_one',
                    items:[
                      {image: 'img.alicdn.com/tfs/TB1OFP3bb1YBuNjSszhXXcUsFXa-950-144.png', scheme: ''}
                    ]
                  },
                  {
                    style: 'small_one',
                    items:[
                      {image: 'img.alicdn.com/tfs/TB1OFP3bb1YBuNjSszhXXcUsFXa-950-144.png', scheme: ''}
                    ]
                  },
                  {
                    style: 'sliding_three',
                    itmes:[
                      {image: 'cdn.pinduoduo.com/assets/img/cat_clothes.jpg', scheme: '', title: '日期二'},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_global_haitao_v1.jpg', scheme: '', title: '去玩儿'},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_global_haitao_v1.jpg', scheme: '', title: '是的发送'}
                    ]
                  },
                  {
                    section_bars: 'cdn.pinduoduo.com/assets/img/pdd_index_jixian_banner.jpg',
                    style: 'left_large_one_right_two',
                    items:[
                      {image: 'cdn.pinduoduo.com/assets/img/cat_girlshoes.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/cat_boyshirt.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/cat_general.jpg', scheme: ''}
                    ]
                  },
                  {
                    section_bars: 'cdn.pinduoduo.com/assets/img/pdd_index_jixian_banner.jpg',
                    style: 'six_three',
                    items:[
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_super_spike_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_super_spike_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_super_spike_v1.jpg', scheme: ''}
                    ]
                    
                  },
                  {
                    section_bars: 'cdn.pinduoduo.com/assets/img/pdd_index_jixian_banner.jpg',
                    style: 'sliding_three',
                    items:[
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''},
                      {image: 'cdn.pinduoduo.com/assets/img/pdd_brand_sale_v1.jpg', scheme: ''}
                    ]
                  }
                            ],
                banners: [{image: 'https://img.alicdn.com/simba/img/TB1sBZkcf5TBuNjSspcSuvnGFXa.jpg'}],
                channel: {
                  background: 'https://img.alicdn.com/simba/img/TB111ELXDCWBKNjSZFtSuuC3FXa.jpg',
                  items:[
                    {image: 'img.alicdn.com/tfs/TB1qpwlQXXXXXcCXXXXXXXXXXXX-256-256.png_60x60.jpg_.webp', scheme: nil},
                    {image: 'img.alicdn.com/tps/i3/TB1DGkJJFXXXXaZXFXX07tlTXXX-200-200.png_60x60.jpg_.webp', scheme: nil},
                    {image: 'img.alicdn.com/tps/i4/TB1zkDeIFXXXXXrXVXX07tlTXXX-200-200.png_60x60.jpg_.webp', scheme: nil},
                    {image: 'img.alicdn.com/tps/i2/TB1kUwwIXXXXXXqXpXXUAkPJpXX-87-87.png_60x60.jpg_.webp', scheme: nil}
                  ]
                }            
            }          
          end  
        end  
      end  
    end  
  end  
end  