# Seed Never Have I Ever cards
puts "Seeding Never Have I Ever cards..."

# Tame cards (family-friendly-ish)
tame_cards = [
  "Yo nunca nunca he fingido estar dormido para no hacer algo",
  "Yo nunca nunca he comido comida del suelo",
  "Yo nunca nunca he cantado en la ducha",
  "Yo nunca nunca he hablado solo",
  "Yo nunca nunca he visto una pelicula de miedo tapandome los ojos",
  "Yo nunca nunca he llorado viendo una pelicula",
  "Yo nunca nunca he fingido saber de un tema del que no tengo idea",
  "Yo nunca nunca he olvidado el cumpleanos de alguien importante",
  "Yo nunca nunca me he quedado dormido en clase o en una reunion",
  "Yo nunca nunca he stalkeado a alguien en redes sociales",
  "Yo nunca nunca he enviado un mensaje al chat equivocado",
  "Yo nunca nunca he mentido sobre mi edad",
  "Yo nunca nunca he fingido una llamada para escapar de una situacion",
  "Yo nunca nunca me he comido algo de la nevera que no era mio",
  "Yo nunca nunca he leido el diario o mensajes de alguien mas",
  "Yo nunca nunca me he saltado hacer ejercicio despues de decir que lo haria",
  "Yo nunca nunca he dicho 'estoy llegando' cuando todavia estaba en casa",
]

# Spicy cards (more adult themes)
spicy_cards = [
  "Yo nunca nunca he besado a alguien del mismo sexo",
  "Yo nunca nunca he tenido un sueno erotico con un amigo",
  "Yo nunca nunca he enviado un mensaje subido de tono",
  "Yo nunca nunca he tenido un crush con el novio/a de un amigo",
  "Yo nunca nunca me han rechazado cuando intente ligar",
  "Yo nunca nunca he usado una app de citas",
  "Yo nunca nunca he hecho ghosting a alguien",
  "Yo nunca nunca me he besado con alguien en la primera cita",
  "Yo nunca nunca he mandado una foto que luego me arrepenti",
  "Yo nunca nunca he llorado por un ex",
  "Yo nunca nunca he espiado el celular de mi pareja",
  "Yo nunca nunca he tenido una cita a ciegas",
  "Yo nunca nunca he vuelto con un ex",
  "Yo nunca nunca he tenido un 'amigo con derechos'",
  "Yo nunca nunca he ligado estando en una relacion",
  "Yo nunca nunca he fingido un orgasmo",
  "Yo nunca nunca he tenido un one night stand",
  "Yo nunca nunca me he enamorado de alguien prohibido",
  "Yo nunca nunca he mandado un nude",
  "Yo nunca nunca he sido infiel",
  "Yo nunca nunca me han sido infiel",
  "Yo nunca nunca he terminado una relacion por texto",
  "Yo nunca nunca he tenido una aventura de verano",
  "Yo nunca nunca he dicho 'te amo' sin sentirlo",
]

# Extreme cards (very adult/embarrassing)
extreme_cards = [
  "Yo nunca nunca he hecho algo sexual en un lugar publico",
  "Yo nunca nunca he participado en un trio",
  "Yo nunca nunca he sido arrestado",
  "Yo nunca nunca he probado drogas ilegales",
  "Yo nunca nunca me he despertado sin saber donde estaba",
  "Yo nunca nunca he vomitado en un Uber o taxi",
  "Yo nunca nunca he tenido relaciones con un companero de trabajo",
  "Yo nunca nunca he mentido en una entrevista de trabajo sobre algo importante",
  "Yo nunca nunca he falsificado un documento",
  "Yo nunca nunca me he escabullido de pagar en un restaurante",
  "Yo nunca nunca he robado algo",
  "Yo nunca nunca he tenido relaciones con alguien que acababa de conocer",
  "Yo nunca nunca he conducido borracho",
  "Yo nunca nunca me he desnudado en publico",
  "Yo nunca nunca he sido expulsado de un bar o club",
  "Yo nunca nunca he hecho algo de lo que me averguenzo tanto que nunca lo contare",
  "Yo nunca nunca he mentido a un policia",
  "Yo nunca nunca me he metido en una pelea fisica",
  "Yo nunca nunca he sido el otro/la otra en una relacion",
  "Yo nunca nunca he hecho algo sexual por dinero o regalos",
]

# Create all cards
tame_cards.each do |content|
  NeverHaveIEverCard.find_or_create_by!(content: content) do |card|
    card.category = :tame
  end
end

spicy_cards.each do |content|
  NeverHaveIEverCard.find_or_create_by!(content: content) do |card|
    card.category = :spicy
  end
end

extreme_cards.each do |content|
  NeverHaveIEverCard.find_or_create_by!(content: content) do |card|
    card.category = :extreme
  end
end

puts "Never Have I Ever cards created:"
puts "  Tame: #{NeverHaveIEverCard.tame.count}"
puts "  Spicy: #{NeverHaveIEverCard.spicy.count}"
puts "  Extreme: #{NeverHaveIEverCard.extreme.count}"
puts "  Total: #{NeverHaveIEverCard.count}"
