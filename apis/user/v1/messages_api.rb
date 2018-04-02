module V1
  module User
    class MessagesAPI < Grape::API
      namespace :user do
        resources :messages do
          
          desc "消息通知列表"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end  
          get do
            begin
              authenticate_user
                {title: '学会这个妆，拍照不用PS', 
                  image: 'https://gogo-bj.oss-cn-beijing.aliyuncs.com/app/touxiang.png?x-oss-process=style/160w', 
                  message_type: 'service', 
                  scheme: 'www.baidu.com', 
                  status: true,
                  time: Time.now.localtime.localtime.strftime('%y/%m/%d')
                }
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end 
          
          desc "消息详情"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            optional :type, type: String, values: ['service', 'personal'], default: 'service', desc: 'service: 系统消息, personal: 个人消息'            
          end
          get :destail do
            begin
              authenticate_user
              [
                {
                  title: "学会这个妆，拍照不用PS",
                  image: 'https://gogo-bj.oss-cn-beijing.aliyuncs.com/app/recommend_product.png?x-oss-process=style/160w',
                  body: '学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS'
                },
                {
                  title: nil,
                  image: nil,
                  body: '学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS学会这个妆，拍照不用PS'
                }                
              ]
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end                          
          end     
        end  
      end  
    end  
  end  
end  