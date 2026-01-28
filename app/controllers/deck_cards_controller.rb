class DeckCardsController < ApplicationController
  before_action :require_registered_user
  before_action :set_deck
  before_action :require_deck_owner
  before_action :set_card, only: [:edit, :update, :destroy]

  def index
    @black_cards = @deck.black_cards
    @white_cards = @deck.white_cards
  end

  def new
    @card = @deck.owned_cards.build(card_type: params[:card_type] || :white)
  end

  def create
    @card = @deck.owned_cards.build(card_params)

    if @card.save
      respond_to do |format|
        format.html { redirect_to deck_deck_cards_path(@deck), notice: 'Carta agregada' }
        format.turbo_stream
      end
    else
      flash.now[:alert] = @card.errors.full_messages.join(', ')
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @card.update(card_params)
      respond_to do |format|
        format.html { redirect_to deck_deck_cards_path(@deck), notice: 'Carta actualizada' }
        format.turbo_stream
      end
    else
      flash.now[:alert] = @card.errors.full_messages.join(', ')
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @card.destroy

    respond_to do |format|
      format.html { redirect_to deck_deck_cards_path(@deck), notice: 'Carta eliminada' }
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@card) }
    end
  end

  def bulk_create
    cards_data = params[:cards] || []
    card_type = params[:card_type] || 'white'

    created_count = 0
    cards_data.each do |content|
      content = content.strip
      next if content.blank?

      card = @deck.owned_cards.build(
        content: content,
        card_type: card_type,
        pick_count: card_type == 'black' ? count_blanks(content) : 1
      )
      created_count += 1 if card.save
    end

    redirect_to deck_deck_cards_path(@deck), notice: "#{created_count} cartas agregadas"
  end

  private

  def set_deck
    @deck = Deck.find(params[:deck_id])
  end

  def set_card
    @card = @deck.owned_cards.find(params[:id])
  end

  def require_deck_owner
    unless @deck.creator_id == current_user&.id
      redirect_to deck_path(@deck), alert: 'No tienes permiso'
    end
  end

  def card_params
    params.require(:card).permit(:content, :card_type, :pick_count, :meme_type, :meme_url)
  end

  def count_blanks(content)
    count = content.scan('_____').count
    count.zero? ? 1 : [count, 3].min
  end
end
