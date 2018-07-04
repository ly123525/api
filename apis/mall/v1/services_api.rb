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
              app_error("订单未支付,无法申请售后", "No Pay! Can't Apply!")  if order.created?      
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
            optional :image1, type: File, desc: '上传凭证1'
            optional :image2, type: File, desc: '上传凭证2'
            optional :image3, type: File, desc: '上传凭证3'
          end
          post :order do
            begin
              authenticate_user
              order = @session_user.orders.find_uuid(params[:order_uuid])
              service=nil
              order.with_lock do
                app_error("订单未支付,无法申请售后", "No Pay! Can't Apply!")  if order.created?
                app_error("有未处理完的售后单,请勿重新申请", "Has One! Can't Apply!")  if order.has_servicing?
                refund_fee = order.total_fee
                service = ::Mall::Service.type_of_service!(  order, params[:type_of],
                                                             params[:refund_cause], params[:mobile],
                                                             params[:description], refund_fee,
                                                             @session_user)
                service.create_picture!(params[:image1], params[:image2], params[:image3])
              end
              present service, with: ::V1::Entities::Service::CreateServiceResult
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end  
          end
          # desc "子订单服务单生成"
          # params do
          #   requires :user_uuid, type: String, desc: '用户 UUID'
          #   requires :token, type: String, desc: '用户访问令牌'
          #   requires :order_item_uuid, type: String, desc: '子订单UUID'
          #   requires :type_of, type: String, values: ['RefundService','ReturnAllService']
          #   requires :refund_cause, type: String, values: ['买错了', '不想买了', '其他'], desc: '退款原因'
          #   requires :description, type: String, desc: '退款说明'
          #   optional :mobile,  type: String, desc: '联系电话'
          #   optional :images, type: Array[File], desc: '上传凭证'
          # end
          # post :item_order do
          #   begin
          #     authenticate_user
          #     order_item = ::Mall::OrderItem.find_uuid(params[:order_item_uuid])
          #     refund_fee = order_item.total_price
          #     service = ::Mall::Service.type_of_service!(  order_item, params[:type_of],
          #                                       params[:refund_cause], params[:mobile],
          #                                       params[:description], refund_fee,
          #                                       @session_user)
          #     service.create_picture!(params[:images])
          #     nil
          #   rescue ActiveRecord::RecordNotFound
          #     app_uuid_error
          #   rescue Exception => ex
          #     server_error(ex)
          #   end
          # end
          desc "售后详情,选择快递"
          params do 
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'
          end        
          get :express do
            begin
              authenticate_user
              service = @session_user.mall_services.find_uuid(params[:uuid])
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
            requires :express, type: String, values: ['圆通','申通', '中通','顺丰','韵达','汇通', '其他'] ,desc: '快递名称'
            requires :express_number, type: String, desc: '快递编号'
          end
          post :express do    
            begin
              authenticate_user
              service = @session_user.mall_services.find_uuid(params[:uuid])
              service.update!(express: params[:express], express_number: params[:express_number])
              service.user_delivery!
              true
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
              service = @session_user.mall_services.find_uuid(params[:uuid])
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
              service = @session_user.mall_services.find_uuid(params[:uuid])
              service.close!
              service.service_target.update(updated_at: Time.now)
              true
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end 
          end
          
          desc "进入修改申诉页面"
          params do 
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '服务单UUID'            
          end
          get :edit do
            begin
              authenticate_user
              service = @session_user.mall_services.find_uuid(params[:uuid])
              present service, with: ::V1::Entities::Service::EditService
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
            requires :refund_cause, type: String, values: ['买错了', '不想买了', '其他'], desc: '退款原因'
            requires :description, type: String, desc: '退款说明'
            optional :mobile,  type: String, desc: '联系电话'
            optional :delete_image_url, type: Array[String], desc: '删除的图片的url'
            optional :image1, type: File, desc: '上传凭证1'
            optional :image2, type: File, desc: '上传凭证2'
            optional :image3, type: File, desc: '上传凭证3'
          end
          post :update do
            begin
              authenticate_user
              service = @session_user.mall_services.find_uuid(params[:uuid])
              service.with_lock do
                app_error("商家已受理,无法修改", "Applyed! Can't modify!")  unless service.created?
                service.update!(description: params[:description], mobile: params[:mobile], refund_cause: params[:refund_cause])
                service.update_picture!(params[:image1], params[:image2], params[:image3], params[:delete_image_url])
                service.service_target.update(updated_at: Time.now)
                true
              end
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
            optional :page, type: Integer, default: 1, desc: '分页页码'
          end
          get :services do
            begin
              authenticate_user
              services = @session_user.mall_services.reorder(updated_at: :desc).page(params[:page]).per(10)
              inner_app = inner_app? request
              present services, with: ::V1::Entities::Service::Services, inner_app: inner_app
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