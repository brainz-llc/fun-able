module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :set_json_format

      private

      def set_json_format
        request.format = :json
      end

      def render_success(data = {}, status: :ok)
        render json: { success: true, data: data }, status: status
      end

      def render_error(message, status: :unprocessable_entity)
        render json: { success: false, error: message }, status: status
      end
    end
  end
end
