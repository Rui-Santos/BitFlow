BitFlow::Application.routes.draw do
  devise_for :users

  resources :asks, :except => [:edit, :update]
  resources :bids, :except => [:edit, :update]
  resources :orders, :only => [:index, :new]
  resources :trades, :only => [:index, :show]
  resources :funds, :only => [:create] do
    collection do
      get 'deposit'
      get 'withdraw'
    end
  end

  match '/user' => "welcome#index", :as => :user_root

  devise_scope :user do
    get "/login" => "devise/sessions#new"
    get "/signout" => "devise/sessions#destroy"
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.
  
  match 'wallet' => 'welcome', :via => :get
  
  match 'admin_setting/edit' => 'admin_setting#edit', :via => :get
  match 'admin_setting' => 'admin_setting#update', :via => :post

  namespace :admin do
    match 'deposits' => 'funds#all_deposits'
    match 'withdrawls' => 'funds#all_withdrawls'
  end

  root :to => "home#index"

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
