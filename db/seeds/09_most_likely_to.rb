# Seed the Most Likely To cards
puts "Seeding Most Likely To cards..."

cards = [
  # Party / Fiesta
  { content: "llegue tarde a su propia fiesta de cumpleanos", category: "party" },
  { content: "se quede dormido en la fiesta", category: "party" },
  { content: "empiece a bailar sin musica", category: "party" },
  { content: "sea el alma de la fiesta", category: "party" },
  { content: "tome shots con extraños", category: "party" },
  { content: "termine cantando karaoke a las 4am", category: "party" },
  { content: "pierda sus llaves en una fiesta", category: "party" },
  { content: "invite a toda la fiesta a su casa despues", category: "party" },

  # Embarrassing / Vergonzoso
  { content: "se caiga en publico", category: "embarrassing" },
  { content: "mande un mensaje al grupo equivocado", category: "embarrassing" },
  { content: "llame a su jefe 'mama' por accidente", category: "embarrassing" },
  { content: "olvide el nombre de alguien que acaba de conocer", category: "embarrassing" },
  { content: "tenga comida en los dientes todo el dia sin saberlo", category: "embarrassing" },
  { content: "salude a alguien que no lo estaba saludando", category: "embarrassing" },
  { content: "se quede encerrado fuera de su casa", category: "embarrassing" },
  { content: "cuente un chiste que nadie entienda", category: "embarrassing" },
  { content: "hable solo en publico sin darse cuenta", category: "embarrassing" },

  # Success / Exito
  { content: "se haga millonario", category: "success" },
  { content: "sea famoso en redes sociales", category: "success" },
  { content: "gane la loteria y no le diga a nadie", category: "success" },
  { content: "escriba un libro bestseller", category: "success" },
  { content: "aparezca en television", category: "success" },
  { content: "sea el primero en casarse", category: "success" },
  { content: "tenga un yate algun dia", category: "success" },

  # Habits / Habitos
  { content: "llegue tarde a todo", category: "habits" },
  { content: "coma directamente del refrigerador a las 3am", category: "habits" },
  { content: "olvide donde dejo su celular 10 veces al dia", category: "habits" },
  { content: "duerma con 50 alarmas y no escuche ninguna", category: "habits" },
  { content: "hable dormido", category: "habits" },
  { content: "haga planes y los cancele a ultimo momento", category: "habits" },
  { content: "pase todo el dia en pijama", category: "habits" },
  { content: "tenga 1000 pestanas abiertas en el navegador", category: "habits" },
  { content: "deje visto y nunca conteste", category: "habits" },

  # Relationships / Relaciones
  { content: "stalkee a su ex en redes sociales", category: "relationships" },
  { content: "se case primero", category: "relationships" },
  { content: "tenga una relacion a distancia", category: "relationships" },
  { content: "olvide su aniversario", category: "relationships" },
  { content: "vuelva con su ex", category: "relationships" },
  { content: "tenga mas de 5 hijos", category: "relationships" },
  { content: "se case en Las Vegas sin avisar", category: "relationships" },
  { content: "le de like accidental a una foto vieja del crush", category: "relationships" },

  # Funny / Divertido
  { content: "sobreviva a un apocalipsis zombie", category: "funny" },
  { content: "se pelee con una paloma", category: "funny" },
  { content: "grite en una pelicula de terror", category: "funny" },
  { content: "se ria en un momento inapropiado", category: "funny" },
  { content: "hable con animales cuando esta solo", category: "funny" },
  { content: "tenga una mascota exotica", category: "funny" },
  { content: "se disfrace de algo ridiculo por una apuesta", category: "funny" },
  { content: "termine en un video viral vergonzoso", category: "funny" },
  { content: "sea abducido por aliens", category: "funny" },
  { content: "crea en fantasmas despues de los 40", category: "funny" },

  # Spicy / Picante
  { content: "tenga un romance de oficina", category: "spicy" },
  { content: "mande un nude al grupo equivocado", category: "spicy" },
  { content: "tenga un one night stand en un viaje", category: "spicy" },
  { content: "coquetee para conseguir algo gratis", category: "spicy" },
  { content: "tenga una relacion secreta", category: "spicy" },
  { content: "bese a un desconocido en año nuevo", category: "spicy" },
  { content: "sea descubierto haciendo algo indebido", category: "spicy" },
  { content: "mienta sobre su experiencia romantica", category: "spicy" },

  # General
  { content: "olvide una fecha importante", category: "general" },
  { content: "gaste todo su sueldo el primer dia", category: "general" },
  { content: "se mude a otro pais", category: "general" },
  { content: "adopte un gato callejero", category: "general" },
  { content: "aprenda otro idioma por un crush", category: "general" },
  { content: "deje todo y viaje por el mundo", category: "general" },
  { content: "gane una discusion que claramente perdio", category: "general" },
  { content: "termine en la carcel (por algo menor)", category: "general" },
  { content: "sea el primero en llorar en una boda", category: "general" },
  { content: "haga un tatuaje impulsivo", category: "general" },
  { content: "salga en un reality show", category: "general" },
  { content: "tenga un canal de YouTube exitoso", category: "general" },
  { content: "sea el ultimo en enterarse del chisme", category: "general" },
  { content: "invente una excusa elaborada para no ir a algo", category: "general" },
  { content: "confunda la sal con el azucar", category: "general" },
  { content: "se queme cocinando agua", category: "general" },
]

cards.each do |card_data|
  MostLikelyToCard.find_or_create_by!(content: card_data[:content]) do |card|
    card.category = card_data[:category]
  end
end

puts "Created #{MostLikelyToCard.count} Most Likely To cards"
