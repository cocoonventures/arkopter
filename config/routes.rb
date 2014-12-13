Arkopter::Application.routes.draw do
  get "orders/new"
  get "orders/create"
  get "orders/update"
  get "orders/edit"
  get "orders/destroy"
  get "orders/index"
  get "orders/show"
  get "quad_arkopters/new"
  get "quad_arkopters/create"
  get "quad_arkopters/update"
  get "quad_arkopters/edit"
  get "quad_arkopters/destroy"
  get "quad_arkopters/index"
  get "quad_arkopters/show"
  get "quad_arkopterss/new"
  get "quad_arkopterss/create"
  get "quad_arkopterss/update"
  get "quad_arkopterss/edit"
  get "quad_arkopterss/destroy"
  get "quad_arkopterss/index"
  get "quad_arkopterss/show"
  get "products/new"
  get "products/create"
  get "products/update"
  get "products/edit"
  get "products/destroy"
  get "products/index"
  get "products/show"
  get "stock_items/new"
  get "stock_items/create"
  get "stock_items/update"
  get "stock_items/edit"
  get "stock_items/destroy"
  get "stock_items/index"
  get "stock_items/show"
  get "users/new"
  get "users/create"
  get "users/update"
  get "users/edit"
  get "users/destroy"
  get "users/index"
  get "users/show"
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
