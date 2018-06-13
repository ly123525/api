module V1
  module Wechat
    class JSAPI < Grape::API
      namespace :wechat do
        resources :js do
          desc "获取微信JS签名包信息"
          params do
            requires :url, type: String, desc: '微信授权的url'
          end
          get 'sign_package' do
            logger.info "================JSAPI:url================#{params[:url]}"
            logger.info "================JSAPI'url'================#{params['url']}"
            $wx_mp_auth.get_jssign_package(URI.decode(params[:url]))
          end
        end
      end
    end
  end
end
