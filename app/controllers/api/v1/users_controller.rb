class Api::V1::UsersController < ApplicationController
  
  skip_before_action :authenticate_request, only: [:create, :confirm_email, :show]
  before_action :find_user, only: [:update, :show]

  def create
    user = User.new(auth_params)
    if user.save
      UserMailer.registration_confirmation(user).deliver
      render json: { message: "A Confirmation email has bent sent to #{user.email}, please confirm it " }
    else
      render json: { error: user.errors }
    end
  end

  

end
