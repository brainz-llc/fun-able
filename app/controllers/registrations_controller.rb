class RegistrationsController < ApplicationController
  before_action :redirect_if_registered, only: [:new, :create]

  def new
    @user = current_user&.guest? ? current_user : User.new
  end

  def create
    if current_user&.guest?
      # Upgrade guest to registered user
      if current_user.upgrade_to_registered!(
        email: user_params[:email],
        password: user_params[:password]
      )
        BrainzLab::Pulse.counter("users.registered")
        BrainzLab::Flux.track_for_user(current_user, "user.registered", upgraded_from_guest: true)
        redirect_to root_path, notice: '¡Cuenta creada exitosamente!'
      else
        @user = current_user
        flash.now[:alert] = current_user.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    else
      @user = User.new(user_params)
      @user.is_guest = false

      if @user.save
        BrainzLab::Pulse.counter("users.registered")
        BrainzLab::Flux.track_for_user(@user, "user.registered", upgraded_from_guest: false)
        login(@user)
        redirect_to root_path, notice: '¡Bienvenido a Cartas Contra la Formalidad!'
      else
        flash.now[:alert] = @user.errors.full_messages.join(', ')
        render :new, status: :unprocessable_entity
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:display_name, :email, :password, :password_confirmation)
  end

  def redirect_if_registered
    redirect_to root_path if logged_in? && !guest_user?
  end
end
