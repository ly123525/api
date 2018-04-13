module V1
  module Mall
    class ServicesAPI < Grape::API
      namespace :mall do
        resources :services do
          desc "进入服务单页面"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单 UUID'            
          end
          get :new do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid])
              present order, with: ::V1::Entities::Service::ServiceOfOrder
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end                           
          end     
          desc "订单服务单生成"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_uuid, type: String, desc: '订单UUID'
            requires :type_of, type: String, values: ['RefundService','ReturnAllService']
            requires :refund_cause, type: String, values: ['买错了', '不想买了', '其他'], desc: '退款原因'
            requires :description, type: String, desc: '退款说明'
            optional :mobile,  type: String, desc: '联系电话'
            optional :images, type: Array[File], desc: '上传凭证'  
          end  
          post :order do
            begin
              authenticate_user
              order = ::Mall::Order.find_uuid(params[:order_uuid])
              refund_fee = order.total_fee
              service = ::Mall::Service.type_of_service!(  order, params[:type_of], 
                                                params[:refund_cause], params[:mobile],
                                                params[:description], refund_fee, 
                                                @session_user)
              service.create_picture!(params[:images])
              present service, with: ::V1::Entities::Service::CreateServiceResult
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end  
          end
          desc "子订单服务单生成"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :order_item_uuid, type: String, desc: '子订单UUID'
            requires :type_of, type: String, values: ['RefundService','ReturnAllService']
            requires :refund_cause, type: String, values: ['买错了', '不想买了', '其他'], desc: '退款原因'
            requires :description, type: String, desc: '退款说明'
            optional :mobile,  type: String, desc: '联系电话'
            optional :images, type: Array[File], desc: '上传凭证'  
          end
          post :item_order do
            begin
              authenticate_user
              order_item = ::Mall::OrderItem.find_uuid(params[:order_item_uuid])
              refund_fee = order_item.total_price
              service = ::Mall::Service.type_of_service!(  order_item, params[:type_of], 
                                                params[:refund_cause], params[:mobile],
                                                params[:description], refund_fee, 
                                                @session_user)
              service.create_picture!(params[:images])                                                                   
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          desc "售后详情,选择快递"
          params do 
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'
          end        
          get :express do
            begin
              authenticate_user
              service = ::Mall::Service.find_uuid(params[:uuid])
              present service, with: ::V1::Entities::Service::DetailServiceOfExpress
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end            
          end
          desc "售后服务提交快递编号"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'
            requires :express, type: String, values: ['圆通','申通', '中通','顺丰','韵达','EMS', '宅急送', '天天' ] ,desc: '快递名称'
            requires :express_number, type: String, desc: '快递编号'
          end
          post :express do    
            begin
              authenticate_user
              service = ::Mall::Service.find_uuid(params[:uuid])
              service.update!(express: params[:express], express_number: params[:express_number])
              {scheme: "http://39.107.86.17:8080/#/mall/services?uuid=#{service.uuid}"}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          desc "售后详情页"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'
          end  
          get do
            begin
              authenticate_user
              service = ::Mall::Service.find_uuid(params[:uuid])
              present service, with: ::V1::Entities::Service::DetailServiceOfProduct
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          desc "取消申请"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID' 
          end
          delete do
            begin
              authenticate_user
              service = ::Mall::Service.find_uuid(params[:uuid])
              service.close!
              true
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end 
          end
          desc "修改申诉"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'
            requires :refund_cause, type: String, values: ['BUY_WRONG','DONT_WANT_BUY','OTHER'], desc: '退款原因'
            requires :description, type: String, desc: '退款说明'
            optional :mobile,  type: String, desc: '联系电话'
            optional :images, type: Array[File], desc: '上传凭证'
          end
          put do
            begin
              authenticate_user
              service = ::Mall::Service.find_uuid(params[:uuid])
              service.update!(refund_cause: params[:refund_cause], description: params[:description], mobile: params[:mobile])
              service.update_picture!(params[:images])
              true
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end   
          end
          
          desc "服务单列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :services do
            begin
              authenticate_user
              services = @session_user.mall_services
              present services, with: ::V1::Entities::Service::Services
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