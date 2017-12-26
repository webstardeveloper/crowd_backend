module Api
  module V1
    class ProjectsController < ApplicationController

      before_action :authenticate_request, only: [:create, :update, :get_draft_project, :fund_project, :launch, :report_project]
      before_action :find_project, only: [:show, :launch, :destroy, :show, :fund_project, :report_project, :get_project_backers]

      def index
        @projects = Project.all.where(aasm_state: "funding")
        render json: @projects, each_serializer: LiteProjectSerializer, status: :ok
      end

      def search_by_category
        category = Category.find_by_name(params[:category])
        @projects = Project.where(category: category, aasm_state: "funding")
        render json: @projects, each_serializer: LiteProjectSerializer , status: :ok
      end

      def create
        result = ProjectService::CreateProject.call(params)
        project = result[:model]
        if result[:status]
          render json: project, status: :created
        else
          render json: project.errors, status: :unprocessable_entity
        end
      end

      def update 
        result = ProjectService::UpdateProject.call(params)
        project = result[:model]
        if result[:status]
          render json: project, status: :created
        else
          render json: project.errors, status: :unprocessable_entity
        end
      end

      def show
        render json: @project, status: :ok
      end

      def view_project_from_mail
        id = params[:id]
        redirect_url = Rails.configuration.email_confirmation['redirect_url']
        redirect_to "#{redirect_url}/projects/#{id}"           
      end

      def launch
        status = @project.launch_project
        if status
          @project.save
          current_user.notifications.create(
            subject: 'Project Launch',
            description: 'Your project was successfully launched, we will notify you once the project is approved by the admin'
          )
        end
        render json: { status: status }
      end

      def get_project_backers
        funding_type = @project.funding_model
        if(funding_type == "flexi")
          render json: @project.backers, each_serializer: LiteUserSerializer 
        else
          backers = @project.future_donors.map do |donor|
            User.find(donor.user_id)
          end
          render json: backers, each_serializer: LiteUserSerializer
        end
      end

      

    end
  end
end
