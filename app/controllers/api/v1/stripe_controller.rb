require 'net/http'

module Api
  module V1
    class StripeController < ApplicationController
      before_action :authenticate_request, only: [:sofort_payments, :card_payments]
      before_action :find_project, only: [:sofort_payments, :card_payments]
      before_action :find_reward, only: [:sofort_payments, :card_payments]

      def card_payments
        token = params[:stripeToken]
        amount = params[:amount]
        funding_type = @project.funding_model

        command = if(funding_type == "flexi")
          CreateCharge.call(token, amount, @current_user, @project, @reward) 
        else
          CreateFutureDonor.call(token, amount, @current_user, @project, @reward)
        end
        
        if command.success?
          message = funding_type == "flexi" ? "You have successfully backed this project"
            : "Thanks for backing this project, We will charge once this project is fully funded"
          render json: { message: message }
        else
          render json: { error: command.errors }
        end
      end

      def sofort_payments
        token = params[:stripeToken]
        amount = params[:amount]
        command = SofortPayment.call(token, amount, @current_user, @project, @reward) 
        if command.success?
          message = "Thanks for backing up this project, Your payment may take upto 14 days to confirm, we will notify you once your payment is confirmed"
          render json: { message: message }
        else
          render json: { error: command.errors }
        end
      end

      
    end
  end
end

