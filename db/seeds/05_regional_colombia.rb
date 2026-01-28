# Seed Colombian regional deck
puts "Seeding Colombian regional deck..."

colombia = Region.find_by(code: 'CO')

deck = Deck.find_or_create_by!(name: 'Expansion Colombiana') do |d|
  d.description = 'Cartas con sabor a Colombia. Parcero, esto es puro humor paisa, costeno, rolo y de todo el pais.'
  d.status = :draft
  d.content_rating = :adult
  d.official = true
  d.region = colombia
end

black_cards = [
  "Parcero, no me vas a creer pero vi _____ en el Exito.",
  "Lo mas chimba de Colombia es _____.",
  "El secreto del sancocho de la abuela es _____.",
  "En la finca del tio siempre hay _____.",
  "El costeño promedio piensa que _____ es lo mejor.",
  "Lo que realmente pasa en las ferias de Cali: _____.",
  "El paisa dice que lo mejor del mundo es _____.",
  "En Bogota te roban hasta _____.",
  "El Eje Cafetero es famoso por _____.",
  "La rumba en Cartagena incluye _____.",
  "El chance que jugo mi tia fue _____.",
  "Los domingos de ciclovia son para _____.",
  "En el estadio gritaron '¡_____!'",
  "El vallenato cuenta la historia de _____.",
  "La arepa perfecta lleva _____.",
  "Lo mas rolo que puedes hacer es _____.",
  "En el TransMilenio vi a alguien con _____.",
  "El man de la tienda siempre ofrece _____.",
]

white_cards = [
  # Colombian expressions & culture
  "Un tinto bien cargado",
  "La empanada de la esquina",
  "El parcero del barrio",
  "Una bandeja paisa completa",
  "El aguardiente del suegro",
  "Los chismes de la tienda",
  "El bus escalera",
  "Las arepas con queso",
  "El sancocho de domingo",
  "La ñapa de la abuela",
  "El chance de la suerte",
  "La ruana del abuelo",
  "El sombrero vueltiao",
  "Las mochilas wayuu",
  "El cafe de Juan Valdez",

  # Colombian situations
  "Decir 'ahora' y demorarse 3 horas",
  "Echarle limon a la sopa",
  "Pedir rebaja en el centro",
  "Ir a misa solo el 31",
  "Guardar las bolsas de Carulla",
  "Llegar 'sobre el tiempo'",
  "Pedir 'un tintico' cada hora",
  "Decir que todo esta 'bien o no'",
  "El trancón de todos los dias",
  "Madrugar para la ciclovía",
  "Apostar en el chance",
  "Pedir fiado en la tienda",
  "Saludar a todo el bus",
  "Quejarse del clima de Bogotá",
  "Ir a Melgar en puente festivo",

  # Regional stereotypes (playful)
  "Un paisa echando carreta",
  "Un rolo con frio",
  "Un costeno bailando",
  "Un pastuso contando chistes",
  "Un santandereano bravo",
  "Un valluno rumbeando",
  "Un boyacense madrugador",
  "Un llanero cantando",
  "Un amazonense en la selva",
  "Un isleño relajado",
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

puts "Colombian deck created with #{deck.black_cards.count} black cards and #{deck.white_cards.count} white cards"
