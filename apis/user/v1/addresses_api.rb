module V1
  module User
    class AddressesAPI < Grape::API
      namespace :user do
        resources :addersses do
          
          desc "添加收货地址"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :name, type: String, desc: '收货人姓名'
            requires :province, type: String, desc: '省份'
            requires :city, type: String, desc: '城市'
            requires :address, type: String, desc: '详细地址'
            requires :phone, type: String, desc: '手机号码'
            optional :is_default, type: Boolean, default: false, desc: '是否默认'
          end
          post do
            begin
              authenticate_user
              app_error("无效的手机号码，请重新输入", "Invalid phone number") unless valid_phone?
              @session_user.addresses.create!(name: params[:name], 
              province: params[:province], 
              city: params[:city], 
              address: params[:address], 
              mobile: params[:phone],
              is_default: params[:is_default])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "编辑收货地址"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '地址UUID'
            requires :name, type: String, desc: '收货人姓名'
            requires :province, type: String, desc: '省份'
            requires :city, type: String, desc: '城市'
            requires :address, type: String, desc: '详细地址'
            requires :phone, type: String, desc: '手机号码'
            optional :is_default, type: Boolean, default: false, desc: '是否默认'
          end
          put do
            begin
              authenticate_user
              app_error("无效的手机号码，请重新输入", "Invalid phone number") unless valid_phone?
              address = @session_user.addresses.find_uuid(params[:uuid])
              address.update!(name: params[:name], 
              province: params[:province], 
              city: params[:city], 
              address: params[:address], 
              mobile: params[:phone],
              is_default: params[:is_default])
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "收货地址列表"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get do
            begin
              authenticate_user
              present @session_user.addresses, with: ::V1::Entities::User::Addresses
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "删除收货地址"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '收货地址 UUID'
          end
          delete do
            begin
              authenticate_user
              @session_user.addresses.find_uuid(params[:uuid]).destroy!
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "使用地址"
          params do
            requires :user_uuid, type: String, desc: '用户 UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :uuid, type: String, desc: '收货地址 UUID'
          end
          post :use do
            begin
              authenticate_user
              address = @session_user.addresses.find_uuid(params[:uuid])
              user_extra = ::Account::UserExtra.find_or_create_by(user: @session_user)
              user_extra.update!(address: address)
            rescue Exception => ex
              server_error(ex)
            end
          end
          
        
        end
        
      end
      
    end
  end
end
