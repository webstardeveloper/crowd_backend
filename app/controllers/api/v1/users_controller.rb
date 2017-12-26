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

  def confirm_email
    user = User.find_by_confirm_token(params[:id])
    if user
      user.email_activate
      message = "Welcome to the CrowdPouch! Your email has been confirmed. Please sign in to continue"
    else
      message = "Email is already confirmed or the user does not exist"
    end

    redirect_url = Rails.configuration.email_confirmation['redirect_url']
    redirect_to "#{redirect_url}?message=#{message}"
  end

  

end
