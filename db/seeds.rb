# This file loads all seed files in order

seed_files = Dir[Rails.root.join('db/seeds/*.rb')].sort

seed_files.each do |seed_file|
  puts "\n=== Loading #{File.basename(seed_file)} ==="
  load seed_file
end

puts "\n=== Seeding complete! ==="
puts "Regions: #{Region.count}"
puts "Decks: #{Deck.count}"
puts "Cards: #{Card.count}"
puts "Victory GIFs: #{VictoryGif.count}"
puts "Never Have I Ever Cards: #{NeverHaveIEverCard.count}" if defined?(NeverHaveIEverCard)
