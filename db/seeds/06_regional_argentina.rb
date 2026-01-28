# Seed Argentine regional deck
puts "Seeding Argentine regional deck..."

argentina = Region.find_by(code: 'AR')

deck = Deck.find_or_create_by!(name: 'Expansion Argentina') do |d|
  d.description = 'Che, boludo, este mazo es puro humor argentino. Asado, mate, futbol y todo lo que nos define.'
  d.status = :draft
  d.content_rating = :adult
  d.official = true
  d.region = argentina
end

black_cards = [
  "Che boludo, no vas a creer que _____ en la cancha.",
  "El secreto del mejor asado es _____.",
  "El argentino promedio piensa que _____ es superior.",
  "En el colectivo vi a un tipo con _____.",
  "La abuela siempre dice que _____ arregla todo.",
  "Lo mas grasa que podes hacer es _____.",
  "En la villa se consigue _____.",
  "El porteno se cree que es mejor en _____.",
  "El cordobes dice '_____ culiau'.",
  "En las elecciones, el politico prometio _____.",
  "El mate amargo va perfecto con _____.",
  "Messi secretamente es fan de _____.",
  "La inflacion ahora incluye _____.",
  "En el kiosco del barrio venden _____.",
  "El psicoanalista opino que _____ es tu problema.",
  "La pizza argentina lleva _____.",
  "En la bailanta habia _____.",
  "Lo mas berreta del pais es _____.",
]

white_cards = [
  # Argentine culture
  "Un asado con los pibes",
  "Mate cocido con bizcochos",
  "Las empanadas salteñas",
  "El dulce de leche artesanal",
  "Un fernet con coca",
  "Las milanesas de la abuela",
  "El choripan del estadio",
  "Los alfajores Havanna",
  "Una picada completa",
  "El quilombo de siempre",

  # Argentine expressions
  "Un boludo con suerte",
  "La concha de la lora",
  "El mambo del laburo",
  "Una mina re copada",
  "El chabón del bondi",
  "La vieja chota",
  "Un pete gratis",
  "El garca del barrio",
  "La yuta corrupta",
  "Un ortiba del orto",

  # Argentine situations
  "Discutir de politica en asado",
  "Quejarse del dolar",
  "Ir al psicologo cada semana",
  "Putear en el transito",
  "Llegar tarde a todo",
  "Decir que somos los mejores",
  "Criticar a otros paises",
  "Llorar con el tango",
  "Ir a la cancha domingo",
  "Hacer cola para todo",

  # Football references
  "El gol de Maradona a los ingleses",
  "La mano de dios",
  "El descenso de River",
  "La bombonera llena",
  "Un penal dudoso",
  "El VAR vendido",
  "La camiseta de Boca",
  "El superclásico",
  "Gritar gol en el barrio",
  "Putear al arbitro",

  # Regional
  "Un cordobés bailando cuarteto",
  "Un porteño agrandado",
  "Un rosarino comiendo asado",
  "Un mendocino con vino",
  "Un entrerriano pescando",
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

puts "Argentine deck created with #{deck.black_cards.count} black cards and #{deck.white_cards.count} white cards"
