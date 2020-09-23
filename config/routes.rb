Rails.application.routes.draw do
  devise_for :users,
             path: '',
             path_names: {
               sign_in: 'login',
               sign_out: 'logout',
               registration: 'signup'
             },
             controllers: {
               sessions: 'sessions',
               registrations: 'registrations'
             }
  namespace :api, defaults: { format: :json } do
    scope module: :v1 do
      resources :subscriptions, only: %i[create destroy]
    end
  end
end
