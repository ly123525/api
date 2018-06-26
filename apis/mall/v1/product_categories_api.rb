module V1
  module Mall
    class ProductCategoriesAPI < Grape::API
      namespace :mall do
        desc "顶级分类"
        params do

        end
        get :top_level_categories do
          begin
            top_categories=::Mall::ProductCategory.top_data_array
          rescue ActiveRecord::RecordNotFound
            app_uuid_error
          rescue Exception => ex
            server_error(ex)
          end
        end
        desc "二级分类和三级分类"
        params do
          requires :top_category_uuid, type: String, desc: "顶级分类uuid"
        end
        get :two_three_level_categories do
          begin
            begin
              top_categories=::Mall::ProductCategory.two_three_date_array(params[:top_category_uuid])
            rescue ActiveRecord::RecordNotFound
              app_uuid_error
            rescue Exception => ex
              server_error(ex)
            end
          end
        end
        desc "商品分类"
        params do
          # requires :admin_uuid, type: String, desc: '商户管理员 UUID'
        end
        get do
          begin
            categories = ::Mall::ProductCategory.data_array
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