module Api
  module V1
    class MemesController < BaseController
      def search
        query = params[:q].to_s.strip
        limit = [params[:limit].to_i, 25].min
        limit = 10 if limit <= 0
        offset = params[:offset].to_i

        if query.blank?
          return render_error('Query is required')
        end

        results = MemeService.search(query, limit: limit, offset: offset)
        render_success(results)
      rescue MemeService::Error => e
        render_error(e.message)
      end

      def trending
        limit = [params[:limit].to_i, 25].min
        limit = 10 if limit <= 0

        results = MemeService.trending(limit: limit)
        render_success(results)
      rescue MemeService::Error => e
        render_error(e.message)
      end

      def victory
        category = params[:category] || 'round_win'
        gif = VictoryGifService.random_for(category.to_sym)

        if gif
          render_success(gif)
        else
          render_error('No GIF found')
        end
      end
    end
  end
end
