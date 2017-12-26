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

     

    end
  end
end
