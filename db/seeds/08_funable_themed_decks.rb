# Seed the Fun-able themed decks
# These are themed expansion packs with specific content categories

puts "Seeding Fun-able themed decks..."

# Load the card content from JSON
content_file = Rails.root.join('db/seeds/card_decks_content.json')
content = JSON.parse(File.read(content_file))

content['decks'].each do |deck_data|
  puts "  Creating deck: #{deck_data['name']}..."

  deck = Deck.find_or_create_by!(name: "Fun-able: #{deck_data['name']}") do |d|
    d.description = deck_data['description']
    d.status = :draft
    d.content_rating = :adult
    d.official = true
  end

  # Clear existing cards if re-seeding
  deck.owned_cards.destroy_all if deck.owned_cards.any?

  # Create black cards (prompts with blanks)
  puts "    Creating #{deck_data['black_cards'].count} black cards..."
  deck_data['black_cards'].each do |content_text|
    blank_count = content_text.scan('_______').count
    blank_count = 1 if blank_count.zero?

    deck.owned_cards.create!(
      content: content_text,
      card_type: :black,
      pick_count: [blank_count, 3].min
    )
  end

  # Create white cards (answers)
  puts "    Creating #{deck_data['white_cards'].count} white cards..."
  deck_data['white_cards'].each do |content_text|
    deck.owned_cards.create!(
      content: content_text,
      card_type: :white,
      pick_count: 1
    )
  end

  deck.update!(status: :published) if deck.playable?

  puts "    #{deck_data['name']} deck created with #{deck.black_cards.count} black cards and #{deck.white_cards.count} white cards"
end

puts "Fun-able themed decks seeding complete!"
puts "  Total themed decks: #{Deck.where('name LIKE ?', 'Fun-able:%').count}"
