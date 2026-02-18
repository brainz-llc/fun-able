class ApplicationController < ActionController::Base
  include Authenticatable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rescue_from StandardError do |exception|
    BrainzLab::Reflex.capture(exception, context: { controller: self.class.name, action: action_name })
    BrainzLab::Signal.trigger("app.unhandled_error", severity: :critical, details: { error: exception.message })
    raise exception
  end

  private

  def set_turbo_frame_request_variant
    request.variant = :turbo_frame if turbo_frame_request?
  end
end
