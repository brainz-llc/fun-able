class MemeService
  class Error < StandardError; end

  GIPHY_API_KEY = ENV.fetch('GIPHY_API_KEY', nil)
  TENOR_API_KEY = ENV.fetch('TENOR_API_KEY', nil)
  CACHE_TTL = 15.minutes

  class << self
    def search(query, limit: 10, offset: 0, provider: :giphy)
      cache_key = "meme_search:#{provider}:#{query}:#{limit}:#{offset}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        case provider
        when :giphy
          search_giphy(query, limit, offset)
        when :tenor
          search_tenor(query, limit, offset)
        else
          raise Error, "Unknown provider: #{provider}"
        end
      end
    end

    def trending(limit: 10, provider: :giphy)
      cache_key = "meme_trending:#{provider}:#{limit}"

      Rails.cache.fetch(cache_key, expires_in: CACHE_TTL) do
        case provider
        when :giphy
          trending_giphy(limit)
        when :tenor
          trending_tenor(limit)
        else
          raise Error, "Unknown provider: #{provider}"
        end
      end
    end

    private

    def search_giphy(query, limit, offset)
      return mock_results(query, limit) unless GIPHY_API_KEY

      response = giphy_client.get('/v1/gifs/search') do |req|
        req.params['api_key'] = GIPHY_API_KEY
        req.params['q'] = query
        req.params['limit'] = limit
        req.params['offset'] = offset
        req.params['rating'] = 'r'
        req.params['lang'] = 'es'
      end

      parse_giphy_response(response)
    rescue Faraday::Error => e
      Rails.logger.error("Giphy search error: #{e.message}")
      BrainzLab::Reflex.capture(e, context: { provider: :giphy, action: :search })
      BrainzLab::Signal.trigger("external_api.failure", severity: :medium, details: { provider: "giphy", action: "search", error: e.message })
      raise Error, "Failed to search GIFs"
    end

    def trending_giphy(limit)
      return mock_results('trending', limit) unless GIPHY_API_KEY

      response = giphy_client.get('/v1/gifs/trending') do |req|
        req.params['api_key'] = GIPHY_API_KEY
        req.params['limit'] = limit
        req.params['rating'] = 'r'
      end

      parse_giphy_response(response)
    rescue Faraday::Error => e
      Rails.logger.error("Giphy trending error: #{e.message}")
      BrainzLab::Reflex.capture(e, context: { provider: :giphy, action: :trending })
      BrainzLab::Signal.trigger("external_api.failure", severity: :medium, details: { provider: "giphy", action: "trending", error: e.message })
      raise Error, "Failed to get trending GIFs"
    end

    def search_tenor(query, limit, offset)
      return mock_results(query, limit) unless TENOR_API_KEY

      response = tenor_client.get('/v2/search') do |req|
        req.params['key'] = TENOR_API_KEY
        req.params['q'] = query
        req.params['limit'] = limit
        req.params['pos'] = offset.to_s
        req.params['contentfilter'] = 'medium'
        req.params['locale'] = 'es_MX'
      end

      parse_tenor_response(response)
    rescue Faraday::Error => e
      Rails.logger.error("Tenor search error: #{e.message}")
      BrainzLab::Reflex.capture(e, context: { provider: :tenor, action: :search })
      BrainzLab::Signal.trigger("external_api.failure", severity: :medium, details: { provider: "tenor", action: "search", error: e.message })
      raise Error, "Failed to search GIFs"
    end

    def trending_tenor(limit)
      return mock_results('trending', limit) unless TENOR_API_KEY

      response = tenor_client.get('/v2/featured') do |req|
        req.params['key'] = TENOR_API_KEY
        req.params['limit'] = limit
        req.params['contentfilter'] = 'medium'
      end

      parse_tenor_response(response)
    rescue Faraday::Error => e
      Rails.logger.error("Tenor trending error: #{e.message}")
      BrainzLab::Reflex.capture(e, context: { provider: :tenor, action: :trending })
      BrainzLab::Signal.trigger("external_api.failure", severity: :medium, details: { provider: "tenor", action: "trending", error: e.message })
      raise Error, "Failed to get trending GIFs"
    end

    def giphy_client
      @giphy_client ||= Faraday.new(url: 'https://api.giphy.com') do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    def tenor_client
      @tenor_client ||= Faraday.new(url: 'https://tenor.googleapis.com') do |f|
        f.request :json
        f.response :json
        f.adapter Faraday.default_adapter
      end
    end

    def parse_giphy_response(response)
      return { gifs: [], pagination: {} } unless response.success?

      data = response.body['data'] || []
      pagination = response.body['pagination'] || {}

      {
        gifs: data.map do |gif|
          {
            id: gif['id'],
            title: gif['title'],
            url: gif.dig('images', 'fixed_height', 'url'),
            preview_url: gif.dig('images', 'fixed_height_small', 'url'),
            width: gif.dig('images', 'fixed_height', 'width'),
            height: gif.dig('images', 'fixed_height', 'height'),
            source: 'giphy'
          }
        end,
        pagination: {
          total_count: pagination['total_count'],
          count: pagination['count'],
          offset: pagination['offset']
        }
      }
    end

    def parse_tenor_response(response)
      return { gifs: [], pagination: {} } unless response.success?

      data = response.body['results'] || []
      next_pos = response.body['next']

      {
        gifs: data.map do |gif|
          media = gif['media_formats']
          {
            id: gif['id'],
            title: gif['content_description'],
            url: media.dig('gif', 'url'),
            preview_url: media.dig('tinygif', 'url'),
            width: media.dig('gif', 'dims', 0),
            height: media.dig('gif', 'dims', 1),
            source: 'tenor'
          }
        end,
        pagination: {
          next: next_pos
        }
      }
    end

    def mock_results(query, limit)
      # Return placeholder data when no API key is configured
      {
        gifs: limit.times.map do |i|
          {
            id: "mock_#{i}",
            title: "#{query} GIF #{i + 1}",
            url: "https://media.giphy.com/media/placeholder/giphy.gif",
            preview_url: "https://media.giphy.com/media/placeholder/giphy-preview.gif",
            width: 200,
            height: 200,
            source: 'mock'
          }
        end,
        pagination: {
          total_count: limit,
          count: limit,
          offset: 0
        }
      }
    end
  end
end
