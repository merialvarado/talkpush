Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :job_applications do
  	collection do
  		get :new_applications
  	end
  end

  root :to => redirect('/job_applications/new_applications')
end
