module V1
  module User
    class UsersAPI < Grape::API
      namespace :user do
        resources :users do
          
          helpers do
            def valid_nickname?
              (2..12).include? params[:nickname].size
            end
          end
          
          desc "个人中心"
          params do
            optional :user_uuid, type: String, desc: '用户UUID'
            optional :token, type: String, desc: '用户访问令牌'
          end
          get :personal_center do
            begin
              authenticate_user_for_weak
              present({user: @session_user}, with: ::V1::Entities::User::PersonalCenter)
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "设置头像"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :image, type: File, desc: '头像'
          end
          patch :head_image do
            begin
              authenticate_user
              ActiveRecord::Base.transaction do
                picture = ::Picture.find_or_create_by!(imageable: @session_user)
                picture.update!(image: params[:image])
              end
              true
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "修改昵称"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :nickname, type: String, desc: '昵称'
          end
          patch :nickname do
            begin
              authenticate_user
              app_error("昵称长度有误！应为2至12个字符，中文、英文各占一个字符", "Nickname length out of range") unless valid_nickname?
              @session_user.update!(nickname: params[:nickname])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "修改性别"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
            requires :sex, type: String, values: ['男', '女'], desc: '性别[男、女]'
          end
          patch :sex do
            begin
              authenticate_user
              @session_user.update!(sex: params[:sex])
              nil
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "友盟 Token 绑定"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :umeng_token, type: String, desc: '友盟 token'
          end
          patch :umeng_token do
            begin
              user = ::Account::User.find_uuid(params[:user_uuid])
              user.update!(umeng_token: params[:umeng_token])
              nil
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "意见反馈"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '友盟 token'
            requires :content, type: String, desc: '内容'
          end
          post :feedback do
            begin
              authenticate_user
              @session_user.feedbacks.create(content: params[:content])
              { tips: '感谢您的宝贵意见' }
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "用户协议"
          params do 
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'            
          end
          get :agreement do
            begin
              authenticate_user
              {scheme:  "lvsent://gogo.cn/web?url=" + Base64.urlsafe_encode64("#{ENV['H5_HOST']}/#/agreement")}
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end
          
          desc "用户信息"
          params do
            requires :user_uuid, type: String, desc: '用户UUID'
            requires :token, type: String, desc: '用户访问令牌'
          end
          get :user_info do
            begin
              authenticate_user
              user=@session_user
              present user, with: ::V1::Entities::User::UserInfo
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
          
          desc "vip社员页"
          params do
            optional :user_uuid, type: String, desc: '用户 UUID'
          end
          get :commune_member do
            begin
              user = ::Account::User.find_uuid params[:user_uuid] rescue nil
              styles = ::Mall::Style.on_sale_by_product.sorted.limit(10)
              inner_app = inner_app? request
              present({user: user}, with: ::V1::Entities::User::VipMember, styles: styles, inner_app: inner_app)
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end              
          end
          
          desc "vip社员页的商品分页"
          params do 
            optional :user_uuid, type: String, desc: '用户 UUID'
            optional :page, type: Integer, default: 2, desc: '分页页码'
          end
          get :page_styles do
            begin
              user = ::Account::User.find_uuid params[:user_uuid] rescue nil
              styles = ::Mall::Style.on_sale_by_product.sorted.page(params[:page]).per(10)
              inner_app = inner_app? request
              present styles, with: ::V1::Entities::Mall::SimpleProductByStyle, inner_app: inner_app
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
