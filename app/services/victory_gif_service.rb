class VictoryGifService
  class << self
    def random_for(category)
      gif = VictoryGif.random_for(category)

      if gif
        {
          url: gif.url,
          source: gif.source,
          category: gif.category
        }
      else
        # Fallback to trending GIF from API
        fallback_gif(category)
      end
    end

    def random_round_win
      random_for(:round_win)
    end

    def random_game_win
      random_for(:game_win)
    end

    private

    def fallback_gif(category)
      search_terms = case category.to_sym
      when :round_win
        %w[celebration winner yes dance party]
      when :game_win
        %w[champion trophy victory confetti fireworks]
      else
        %w[celebration]
      end

      begin
        result = MemeService.search(search_terms.sample, limit: 1)
        gif = result[:gifs].first

        return nil unless gif

        {
          url: gif[:url],
          source: gif[:source],
          category: category.to_s
        }
      rescue MemeService::Error
        nil
      end
    end
  end
end
