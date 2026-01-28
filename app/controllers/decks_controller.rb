class DecksController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :require_registered_user, only: [:new, :create]
  before_action :set_deck, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :vote]
  before_action :require_deck_owner, only: [:edit, :update, :destroy, :publish, :unpublish]

  def index
    @decks = Deck.published.includes(:region, :creator)

    @decks = @decks.by_region(params[:region_id]) if params[:region_id].present?
    @decks = @decks.by_rating(params[:content_rating]) if params[:content_rating].present?

    @decks = case params[:sort]
    when 'recent'
      @decks.recent
    when 'popular'
      @decks.popular
    else
      @decks.popular
    end

    @decks = @decks.page(params[:page]).per(12) if @decks.respond_to?(:page)

    @regions = Region.active.sorted.roots.includes(:children)
  end

  def show
    @black_cards = @deck.black_cards.limit(10)
    @white_cards = @deck.white_cards.limit(20)
  end

  def new
    @deck = current_user.created_decks.build
    @regions = Region.active.sorted
  end

  def create
    @deck = current_user.created_decks.build(deck_params)

    if @deck.save
      redirect_to deck_path(@deck), notice: 'Mazo creado exitosamente'
    else
      @regions = Region.active.sorted
      flash.now[:alert] = @deck.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @regions = Region.active.sorted
  end

  def update
    if @deck.update(deck_params)
      redirect_to deck_path(@deck), notice: 'Mazo actualizado'
    else
      @regions = Region.active.sorted
      flash.now[:alert] = @deck.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @deck.destroy
    redirect_to decks_path, notice: 'Mazo eliminado'
  end

  def publish
    if @deck.publish!
      redirect_to deck_path(@deck), notice: 'Mazo publicado'
    else
      redirect_to deck_path(@deck), alert: 'No se pudo publicar el mazo. Verifica que tenga suficientes cartas.'
    end
  end

  def unpublish
    @deck.draft!
    redirect_to deck_path(@deck), notice: 'Mazo despublicado'
  end

  def vote
    value = params[:value].to_i
    value = value.positive? ? 1 : -1

    @deck.vote_by(current_user, value: value)

    respond_to do |format|
      format.html { redirect_to deck_path(@deck) }
      format.turbo_stream
    end
  end

  def my_decks
    @decks = current_user.created_decks.includes(:region).recent
  end

  private

  def set_deck
    @deck = Deck.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to decks_path, alert: 'Mazo no encontrado'
  end

  def require_deck_owner
    unless @deck.creator_id == current_user&.id
      redirect_to deck_path(@deck), alert: 'No tienes permiso para editar este mazo'
    end
  end

  def deck_params
    params.require(:deck).permit(:name, :description, :region_id, :content_rating)
  end
end
