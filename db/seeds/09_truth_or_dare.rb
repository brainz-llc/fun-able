# Truth or Dare (Verdad o Reto) seed data

puts "Creating Truth Cards..."

# Mild Truths (Suaves)
mild_truths = [
  "Cual es tu pelicula favorita de todos los tiempos?",
  "Cual fue tu primer crush de famoso/a?",
  "Cual es tu comida reconfortante favorita?",
  "Cual es tu recuerdo mas vergonzoso de la infancia?",
  "Cual es la cancion que escuchas a escondidas?",
  "Cual fue la mentira mas inocente que le dijiste a tus padres?",
  "Cual es tu mayor miedo irracional?",
  "Cual es el sueno mas raro que has tenido?",
  "Cual es tu peor habito?",
  "Que es lo mas infantil que todavia haces?",
  "Cual fue tu apodo mas vergonzoso?",
  "Que es lo mas torpe que has hecho en publico?",
  "Cual es tu mayor inseguridad?",
  "Que es lo que mas te molesta de ti mismo?",
  "Cual es tu talento oculto?",
]

# Medium Truths (Medios)
medium_truths = [
  "Cual es el secreto mas grande que le has guardado a tu mejor amigo/a?",
  "Has stalkeado a alguien en redes sociales? A quien?",
  "Cual es la cosa mas loca que has hecho por amor?",
  "Has enviado un mensaje de texto a la persona equivocada? Que decia?",
  "Cual es tu fantasia mas vergonzosa?",
  "Has mentido para salir de una cita? Como lo hiciste?",
  "Cual ha sido tu momento mas incomodo en una relacion?",
  "Has besado a alguien que no deberias? Quien?",
  "Cual es la cosa mas cara que has robado (aunque sea de nino)?",
  "Has fingido estar enfermo/a para evitar algo? Que?",
  "Cual es tu opinion mas impopular?",
  "Has hecho trampa en algo importante? Que?",
  "Cual es tu crush secreto del grupo?",
  "Que es lo mas vergonzoso que tienes en tu telefono?",
  "Has hablado mal de alguien presente? De quien?",
]

# Spicy Truths (Picantes)
spicy_truths = [
  "Cual ha sido tu experiencia romantica mas vergonzosa?",
  "Has tenido un sueno subido de tono con alguien de aqui?",
  "Cual es tu fantasia mas atrevida?",
  "Has mandado fotos comprometedoras? Cuenta!",
  "Cual ha sido tu peor cita? No omitas detalles.",
  "Has hecho algo de lo que te arrepientes estando borracho/a?",
  "Cual es el lugar mas raro donde has besado a alguien?",
  "Has mentido sobre tu experiencia romantica? Que dijiste?",
  "Cual es tu mayor arrepentimiento en el amor?",
  "Has tenido un amigo/a con derechos? Como termino?",
  "Cual es la cosa mas atrevida que has hecho en publico?",
  "Has stalkeado al ex de tu pareja? Que encontraste?",
  "Cual es tu secreto mas oscuro que nadie sabe?",
  "Has besado a mas de una persona en la misma noche?",
  "Que es lo mas vergonzoso que has buscado en internet?",
]

# Create Truth Cards
mild_truths.each do |content|
  TruthCard.find_or_create_by!(content: content, intensity: :mild)
end

medium_truths.each do |content|
  TruthCard.find_or_create_by!(content: content, intensity: :medium)
end

spicy_truths.each do |content|
  TruthCard.find_or_create_by!(content: content, intensity: :spicy)
end

puts "Created #{TruthCard.count} Truth Cards"

puts "Creating Dare Cards..."

# Mild Dares (Suaves)
mild_dares = [
  "Haz tu mejor imitacion de un animal durante 30 segundos",
  "Canta el coro de tu cancion favorita",
  "Baila sin musica durante 1 minuto",
  "Cuenta un chiste malo",
  "Haz 10 sentadillas",
  "Habla con acento extranjero por 2 rondas",
  "Deja que alguien publique algo en tu estado de WhatsApp",
  "Muestra la ultima foto de tu galeria",
  "Imita a la persona de tu izquierda",
  "Di un piropo cursi a cada persona del grupo",
  "Haz una pose de modelo y mantenerla por 30 segundos",
  "Cuenta una historia usando solo emojis",
  "Canta el himno nacional haciendo flexiones",
  "Actua como si fueras un bebe por 1 minuto",
  "Deja que el grupo cambie tu foto de perfil por 24 horas",
]

# Medium Dares (Medios)
medium_dares = [
  "Deja que alguien escriba un mensaje a quien ellos quieran desde tu telefono",
  "Llama a la ultima persona que te llamo y cantale una cancion",
  "Publica una selfie vergonzosa en tus redes",
  "Deja que te maquillen con los ojos cerrados",
  "Haz una confesion vergonzosa en tu estado de WhatsApp",
  "Imita el baile de TikTok mas viral que conozcas",
  "Llama a un familiar y dile que te casaste",
  "Deja que el grupo revise tus ultimos 5 mensajes de texto",
  "Haz una declaracion de amor dramatica a una silla",
  "Actua una escena romantica de pelicula solo/a",
  "Intenta lamer tu codo por 30 segundos",
  "Cuenta tu momento mas vergonzoso con lujo de detalles",
  "Deja que te peinen como quieran",
  "Haz un video de TikTok ahora mismo",
  "Coquetea con la pared como si fuera tu crush",
]

# Spicy Dares (Picantes)
spicy_dares = [
  "Besa la mano de la persona que elija el grupo",
  "Da un masaje de hombros a alguien del grupo",
  "Actua tu mejor tecnica de seduccion",
  "Deja que alguien te escriba en la frente con marcador",
  "Susurrale algo al oido a la persona de tu derecha",
  "Haz un baile sensual por 30 segundos",
  "Siéntate en las piernas de alguien por el resto de la ronda",
  "Deja que el grupo elija tu foto de Tinder",
  "Actua como si estuvieras enamorado/a de alguien del grupo",
  "Quitate una prenda (puede ser un calcetin)",
  "Deja que alguien te maquille los labios con los ojos vendados",
  "Haz tu mejor cara de 'modelo de revista'",
  "Graba un audio diciendole a alguien que lo/la extranas",
  "Deja que revisen tu carpeta de fotos eliminadas",
  "Actua un beso de pelicula con un cojin",
  "Hazle un cumplido atrevido a cada persona del grupo",
]

# Create Dare Cards
mild_dares.each do |content|
  DareCard.find_or_create_by!(content: content, intensity: :mild)
end

medium_dares.each do |content|
  DareCard.find_or_create_by!(content: content, intensity: :medium)
end

spicy_dares.each do |content|
  DareCard.find_or_create_by!(content: content, intensity: :spicy)
end

puts "Created #{DareCard.count} Dare Cards"
puts "Truth or Dare seeding complete!"
