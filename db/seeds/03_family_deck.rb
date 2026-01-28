# Seed the family-friendly deck
puts "Seeding family deck..."

deck = Deck.find_or_create_by!(name: 'Mazo Familiar') do |d|
  d.description = 'Version apta para toda la familia. Sin contenido adulto ni groserías.'
  d.status = :draft
  d.content_rating = :family
  d.official = true
end

black_cards = [
  "Lo mejor de las vacaciones es _____.",
  "Mi superpoder seria _____.",
  "El secreto de la felicidad es _____.",
  "_____ es lo mas divertido del mundo.",
  "En mi cumpleanos quiero _____.",
  "Mi animal favorito es _____ porque _____.",
  "La mejor comida del mundo es _____.",
  "Si fuera invisible haria _____.",
  "_____ es el mejor regalo.",
  "Mi personaje de pelicula favorito es _____.",
  "El pasatiempo mas divertido es _____.",
  "_____ me hace reir mucho.",
  "La mejor parte de la escuela es _____.",
  "Si pudiera volar iria a _____.",
  "_____ es la mejor mascota.",
  "El mejor dia de la semana es _____ porque _____.",
  "Mi lugar favorito es _____.",
  "_____ es lo mas cool.",
  "La musica que me gusta es _____.",
  "Si fuera un superhéroe mi nombre seria _____.",
]

white_cards = [
  "Un abrazo de oso",
  "Helado de chocolate",
  "Los perros juguetones",
  "Saltar en charcos",
  "Las peliculas de Disney",
  "Un dia de playa",
  "La risa de un bebe",
  "Los arcoiris",
  "Globos de colores",
  "Las estrellas fugaces",
  "Un pastel de cumpleanos",
  "Los dinosaurios",
  "Hacer castillos de arena",
  "Los fuegos artificiales",
  "Un dia de campo",
  "Las mariposas",
  "Jugar futbol",
  "Los unicornios",
  "Comer pizza",
  "Ver caricaturas",
  "Montar bicicleta",
  "Los columpios",
  "Hacer burbujas",
  "Los cuentos antes de dormir",
  "El primer dia de vacaciones",
  "Encontrar un tesoro",
  "Un dia nevado",
  "Los gatos dormilones",
  "Ganar un juego",
  "Las cosquillas",
  "Comer fruta",
  "El olor a flores",
  "Las pijamadas",
  "Los parques de diversiones",
  "Hacer manualidades",
  "Ver delfines",
  "Cantar en el carro",
  "Los dias de lluvia",
  "Un chocolate caliente",
  "Dormir hasta tarde",
]

black_cards.each do |content|
  blank_count = content.scan('_____').count
  blank_count = 1 if blank_count.zero?

  deck.owned_cards.find_or_create_by!(content: content) do |c|
    c.card_type = :black
    c.pick_count = [blank_count, 3].min
  end
end

white_cards.each do |content|
  deck.owned_cards.find_or_create_by!(content: content) do |c|
    c.card_type = :white
    c.pick_count = 1
  end
end

deck.update!(status: :published) if deck.playable?

puts "Family deck created with #{deck.black_cards.count} black cards and #{deck.white_cards.count} white cards"
