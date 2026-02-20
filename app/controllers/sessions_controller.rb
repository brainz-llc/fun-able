class SessionsController < ApplicationController
  before_action :redirect_if_logged_in, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email]&.downcase&.strip)

    if user&.authenticate(params[:password])
      login(user)
      redirect_back_or root_path
    else
      flash.now[:alert] = 'Correo o contraseña incorrectos'
      render :new, status: :unprocessable_entity
    end
  end

  def create_guest
    guest = User.create_guest!
    BrainzLab::Pulse.counter("users.guest_created")
    BrainzLab::Flux.track_for_user(guest, "user.created", guest: true)
    login(guest)

    respond_to do |format|
      format.html { redirect_back_or root_path }
      format.turbo_stream { redirect_to root_path }
    end
  end

  def destroy
    logout
    redirect_to root_path, notice: '¡Hasta pronto!'
  end

  private

  def redirect_if_logged_in
    redirect_to root_path if logged_in? && !guest_user?
  end
end
