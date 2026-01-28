# Seed Mexican regional deck
puts "Seeding Mexican regional deck..."

mexico = Region.find_by(code: 'MX')

deck = Deck.find_or_create_by!(name: 'Expansion Mexicana') do |d|
  d.description = 'Cartas con humor 100% mexicano. Puro chiste local, modismos y cultura popular de Mexico.'
  d.status = :draft
  d.content_rating = :adult
  d.official = true
  d.region = mexico
end

black_cards = [
  "El Chavo del 8 secretamente era _____.",
  "La verdadera razon por la que el America es odiado: _____.",
  "El OXXO de medianoche es testigo de _____.",
  "Lo que realmente venden en la Lagunilla: _____.",
  "La receta secreta de los tacos de canasta es _____.",
  "El metro de la CDMX huele a _____.",
  "En la feria de San Marcos, lo mas peligroso es _____.",
  "El chilango promedio desayuna _____.",
  "La tanda del trabajo sirve para pagar _____.",
  "El compadre llego a la fiesta con _____.",
  "Lo que realmente pasa en las posadas: _____.",
  "El mariachi a las 3am estaba cantando sobre _____.",
  "La quincena se fue en _____.",
  "El tianguis del domingo ofrece _____.",
  "Las micheladas de tu tio llevan _____.",
  "El chisme de la vecina es que _____ con _____.",
  "En la peda, alguien confeso que _____.",
  "El Buen Fin es la excusa perfecta para _____.",
  "La suegra mexicana siempre critica _____.",
  "Lo mas mexicano que he hecho es _____.",
]

white_cards = [
  # Mexican pop culture
  "Un chisme en el salon de belleza",
  "El senor de los elotes",
  "La fila del banco un viernes",
  "Tacos de birria a las 4am",
  "El traje de charro del abuelo",
  "Las vacaciones en Acapulco de los 90s",
  "El Tigre Toño",
  "Las quesadillas sin queso",
  "Un michelaton de 3 dias",
  "La loteria de la feria",
  "Los tamales de la vecina",
  "El agua de Jamaica de garrafon",
  "Un cafe de olla con pan dulce",
  "Las garnachas de la esquina",
  "El pulque curado de apio",

  # Mexican situations
  "Decir 'ahorita' y nunca hacerlo",
  "Llegar una hora tarde 'puntual'",
  "La cruda despues de una boda",
  "Echarle limon a todo",
  "Pelear por la ultima tortilla",
  "Comprar en abonos chiquitos",
  "Guardar las bolsas del super",
  "Tener una tia que vende Avon",
  "Lavar los trastes con la chancla cerca",
  "Ponerse elegante para ir al Soriana",
  "Decir que 'no pica' cuando pica",
  "Pedir 'poquita salsa' y ahogarse",
  "Ir a Costco solo por las muestras",
  "Presumir que 'conoces a alguien'",
  "Echarle la culpa al aire acondicionado",

  # Mexican expressions as concepts
  "El poder de la chancla",
  "La bendicion de la abuela",
  "El orgullo del barrio",
  "La maldicion del Azteca",
  "El milagro de la Virgen",
  "La magia del pueblo",
  "El encanto de provincia",
  "La tradicion familiar",
  "El ingenio mexicano",
  "La picardía del chilango",

  # Mexican food & drinks
  "Pozole rojo de rancho",
  "Tortas ahogadas nivel extremo",
  "Carnitas de Michoacan",
  "Cochinita pibil autentica",
  "Mole negro oaxaqueno",
  "Chapulines con sal de gusano",
  "Aguachile nivel suicida",
  "Machaca con huevo",
  "Menudo de sabado",
  "El atole de la abuela",
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

puts "Mexican deck created with #{deck.black_cards.count} black cards and #{deck.white_cards.count} white cards"
