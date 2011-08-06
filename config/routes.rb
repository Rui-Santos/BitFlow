BitFlow::Application.routes.draw do

  devise_for :users, :controllers => { :registrations => "registrations" }

  resources :btc_fund_transfers
  resources :user_wallets
  resources :fund_deposits
  resources :users, :only => [:show, :update]
  
  resources :bankaccounts, :only => [:index, :new, :create, :destroy]
  resources :asks, :except => [:edit, :update]
  resources :bids, :except => [:edit, :update]
  resources :orders, :only => [:index, :new]
  resources :trades, :only => [:index, :show] do
    collection do
      get 'price_graph'
    end
  end
  
  match '/faq' => "home#faq"
  match '/about_us' => "home#about_us"
  match '/contact_us' => "home#contact_us"
  match '/latest_updates' => "home#latest_updates"
  match '/trading_api' => "home#trading_api"
  match '/affiliate_program' => "home#affiliate_program"
  match '/terms_of_use' => "home#terms_of_use"
  match '/privacy_policy' => "home#privacy_policy"

  devise_scope :user do
    get "/login" => "devise/sessions#new"
    get "/signout" => "devise/sessions#destroy"
  end

  match '/signin_help' => 'home#signin_help'

  resources :welcome, :only => [:index]

  root :to => "home#index"

  namespace :admin do
    root :to => 'settings#edit'
    match '/signin_help' => 'home#signin_help'
    match 'fund_deposits/search' => 'fund_deposits#search', :via => :post
    resources :orders, :only => [:index, :show], :controllers => 'orders'
    resources :trades, :only => [:index, :show], :controllers => 'trades'

    resources :fund_deposits, :only => [:index, :update], :controllers => 'admin/fund_deposits'

    resources :search_criterias, :controllers => 'admin/fund_deposits'
    match 'settings/update' => 'settings#update', :via => :post
  end

  # api
  match '/v1/balance' => 'api/trade_api#balance'
  match '/v1/orders' => 'api/trade_api#orders'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  #  Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
