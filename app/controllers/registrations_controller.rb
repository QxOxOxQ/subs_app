class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    if resource.errors.empty?
      render json: resource
    else
      render json:
                 { error: {
                   status: '400',
                   title: 'Bad Request',
                   detail: resource.errors,
                   code: '100'
                 } }, status: :bad_request
    end
  end
end
