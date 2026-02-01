# Seed data for Would You Rather (Que Prefieres) game
puts "Seeding Would You Rather cards..."

dilemmas = [
  # Funny / Chistosas
  {
    option_a: "Que tu mama lea todos tus mensajes de WhatsApp",
    option_b: "Que tu jefe vea todo tu historial de navegacion",
    category: "funny"
  },
  {
    option_a: "Tener que cantar todo lo que dices por un dia",
    option_b: "Tener que bailar cada vez que caminas por una semana",
    category: "funny"
  },
  {
    option_a: "Oler a ajo por el resto de tu vida",
    option_b: "Que todos los demas huelan a ajo para ti",
    category: "funny"
  },
  {
    option_a: "Tener hipo por un ano",
    option_b: "Sentir que vas a estornudar pero nunca poder hacerlo por un ano",
    category: "funny"
  },
  {
    option_a: "Que tus pedos sean silenciosos pero mortalmente apestosos",
    option_b: "Que tus pedos suenen como trompeta pero no huelan a nada",
    category: "funny"
  },
  {
    option_a: "Tener que hablar como Cantinflas por un mes",
    option_b: "Tener que caminar como robot por un mes",
    category: "funny"
  },
  {
    option_a: "Que tu vida tenga musica de fondo de telenovela",
    option_b: "Que tu vida tenga risas enlatadas como sitcom",
    category: "funny"
  },
  {
    option_a: "Sudar salsa picante",
    option_b: "Llorar leche",
    category: "funny"
  },
  {
    option_a: "Tener manos por pies",
    option_b: "Tener pies por manos",
    category: "funny"
  },
  {
    option_a: "Que tu ringtone sea un gemido que no puedes cambiar",
    option_b: "Que tu alarma sea tu ex diciendo 'despierta mi amor' cada manana",
    category: "funny"
  },

  # Spicy / Picantes
  {
    option_a: "Saber que tu pareja te engana pero no poder probarlo",
    option_b: "Que todos piensen que tu enganas a tu pareja sin ser cierto",
    category: "spicy"
  },
  {
    option_a: "Besar al ex de tu mejor amigo/a",
    option_b: "Que tu mejor amigo/a bese a tu ex",
    category: "spicy"
  },
  {
    option_a: "Tener sexo increible una vez al ano",
    option_b: "Tener sexo mediocre cuando quieras",
    category: "spicy"
  },
  {
    option_a: "Que todos tus matches de Tinder sean ex companeros de trabajo",
    option_b: "Que todos tus matches sean amigos de tus padres",
    category: "spicy"
  },
  {
    option_a: "Gritar el nombre de tu ex en la intimidad",
    option_b: "Que tu pareja grite el nombre de su ex",
    category: "spicy"
  },
  {
    option_a: "Ver las fotos intimas que tu crush le manda a otros",
    option_b: "Que tu crush vea las fotos intimas que tu mandas a otros",
    category: "spicy"
  },
  {
    option_a: "Ser increiblemente atractivo/a pero malo/a en la cama",
    option_b: "Ser promedio fisicamente pero increible en la cama",
    category: "spicy"
  },
  {
    option_a: "Que tus padres encuentren tus juguetes",
    option_b: "Encontrar los juguetes de tus padres",
    category: "spicy"
  },
  {
    option_a: "Tener que decir todas tus fantasias en voz alta",
    option_b: "Que todos puedan leer tus pensamientos cuando estas excitado/a",
    category: "spicy"
  },
  {
    option_a: "Solo poder tener relaciones en hoteles de paso",
    option_b: "Solo poder tener relaciones en casa de tus padres",
    category: "spicy"
  },

  # Philosophical / Filosoficas
  {
    option_a: "Saber exactamente cuando vas a morir",
    option_b: "Saber exactamente como vas a morir",
    category: "philosophical"
  },
  {
    option_a: "Poder viajar al pasado pero no cambiar nada",
    option_b: "Poder viajar al futuro pero no poder volver",
    category: "philosophical"
  },
  {
    option_a: "Ser extremadamente inteligente pero muy infeliz",
    option_b: "Ser de inteligencia promedio pero muy feliz",
    category: "philosophical"
  },
  {
    option_a: "Vivir 100 anos en soledad",
    option_b: "Vivir 40 anos rodeado de gente que amas",
    category: "philosophical"
  },
  {
    option_a: "Saber toda la verdad del universo pero no poder contarla",
    option_b: "Poder mentir sin que nadie lo detecte nunca",
    category: "philosophical"
  },
  {
    option_a: "Revivir tu mejor momento una y otra vez",
    option_b: "Borrar tu peor recuerdo para siempre",
    category: "philosophical"
  },
  {
    option_a: "Tener todo el dinero del mundo pero ninguna familia",
    option_b: "Tener una familia enorme pero vivir en pobreza",
    category: "philosophical"
  },
  {
    option_a: "Poder leer la mente de todos",
    option_b: "Que todos puedan leer tu mente",
    category: "philosophical"
  },
  {
    option_a: "Ser famoso por algo malo",
    option_b: "Nunca ser recordado por nada",
    category: "philosophical"
  },
  {
    option_a: "Conocer todos los secretos del gobierno",
    option_b: "Que el gobierno conozca todos tus secretos",
    category: "philosophical"
  },

  # Embarrassing / Vergonzosas
  {
    option_a: "Que publiquen todas las fotos borradas de tu celular",
    option_b: "Que publiquen todas tus busquedas de Google del ultimo ano",
    category: "embarrassing"
  },
  {
    option_a: "Vomitar en la primera cita",
    option_b: "Que tu cita vomite en ti",
    category: "embarrassing"
  },
  {
    option_a: "Tropezar y caer en publico todos los dias",
    option_b: "Tener espinacas en los dientes todo el dia sin saberlo",
    category: "embarrassing"
  },
  {
    option_a: "Que tu familia escuche todo lo que dices de ellos",
    option_b: "Que tus amigos vean todo lo que escribes sobre ellos",
    category: "embarrassing"
  },
  {
    option_a: "Quedarte dormido en tu propia boda",
    option_b: "Olvidar el nombre de tu pareja en el altar",
    category: "embarrassing"
  },
  {
    option_a: "Que salga tu foto mas fea en una valla publicitaria",
    option_b: "Que transmitan tu peor momento en television nacional",
    category: "embarrassing"
  },
  {
    option_a: "Llamar 'mama' a tu jefe accidentalmente",
    option_b: "Mandar un mensaje de amor a tu grupo de trabajo",
    category: "embarrassing"
  },
  {
    option_a: "Que tu ex cuente todo sobre ti a tus companeros",
    option_b: "Tener que confesar tus secretos a tu familia",
    category: "embarrassing"
  },
  {
    option_a: "Hacer un sonido de pedo en cada silencio incomodo",
    option_b: "Reir como hiena cada vez que alguien llora",
    category: "embarrassing"
  },
  {
    option_a: "Que lean tus mensajes de texto en voz alta en una fiesta",
    option_b: "Que muestren tus fotos del celular en una pantalla grande",
    category: "embarrassing"
  },

  # Lifestyle / Estilo de Vida
  {
    option_a: "Nunca poder usar redes sociales otra vez",
    option_b: "Nunca poder ver Netflix/streaming otra vez",
    category: "lifestyle"
  },
  {
    option_a: "Vivir sin musica",
    option_b: "Vivir sin peliculas/series",
    category: "lifestyle"
  },
  {
    option_a: "Comer solo tacos por el resto de tu vida",
    option_b: "Nunca mas poder comer tacos",
    category: "lifestyle"
  },
  {
    option_a: "Tener wifi infinito pero sin datos moviles",
    option_b: "Tener datos moviles infinitos pero sin wifi en casa",
    category: "lifestyle"
  },
  {
    option_a: "Trabajar 4 dias de 12 horas",
    option_b: "Trabajar 6 dias de 6 horas",
    category: "lifestyle"
  },
  {
    option_a: "Vivir en una mansion en un pueblo aburrido",
    option_b: "Vivir en un depa pequeno en la ciudad mas divertida",
    category: "lifestyle"
  },
  {
    option_a: "Nunca poder tomar cafe/te otra vez",
    option_b: "Nunca poder tomar alcohol otra vez",
    category: "lifestyle"
  },
  {
    option_a: "Ser millonario pero tener que vestir de payaso siempre",
    option_b: "Tener sueldo normal pero vestir como quieras",
    category: "lifestyle"
  },
  {
    option_a: "Siempre tener frio aunque sea verano",
    option_b: "Siempre tener calor aunque sea invierno",
    category: "lifestyle"
  },
  {
    option_a: "Tener solo 3 horas de sueno pero sentirte descansado",
    option_b: "Necesitar 12 horas de sueno para funcionar",
    category: "lifestyle"
  },

  # Hypothetical / Hipoteticas
  {
    option_a: "Poder volar pero solo a 1 metro del suelo",
    option_b: "Poder ser invisible pero solo cuando nadie te mira",
    category: "hypothetical"
  },
  {
    option_a: "Tener un dragon de mascota pero que queme tu casa cada semana",
    option_b: "Tener un unicornio de mascota pero que hable mal de ti a tus espaldas",
    category: "hypothetical"
  },
  {
    option_a: "Poder hablar con animales pero ellos son muy groseros",
    option_b: "Poder hablar cualquier idioma humano pero con acento de politico",
    category: "hypothetical"
  },
  {
    option_a: "Ser protagonista de una pelicula de terror",
    option_b: "Ser el villano de una pelicula infantil",
    category: "hypothetical"
  },
  {
    option_a: "Tener el poder de pausar el tiempo pero envejeces igual",
    option_b: "Poder retroceder el tiempo 10 segundos pero pierdes un ano de vida",
    category: "hypothetical"
  },
  {
    option_a: "Tener super fuerza pero ser torpe",
    option_b: "Ser super agil pero muy debil",
    category: "hypothetical"
  },
  {
    option_a: "Que todos tus suenos se hagan realidad literalmente",
    option_b: "Nunca volver a sonar",
    category: "hypothetical"
  },
  {
    option_a: "Ser la persona mas inteligente del mundo pero fea",
    option_b: "Ser la persona mas guapa del mundo pero tonta",
    category: "hypothetical"
  },
  {
    option_a: "Poder comer lo que quieras sin engordar",
    option_b: "Solo necesitar dormir 1 hora al dia",
    category: "hypothetical"
  },
  {
    option_a: "Tener un boton de deshacer para tu vida",
    option_b: "Tener un boton de adelantar para los momentos aburridos",
    category: "hypothetical"
  },

  # Extra funny ones
  {
    option_a: "Tener siempre el WiFi lento",
    option_b: "Que siempre se te acabe la bateria al 50%",
    category: "funny"
  },
  {
    option_a: "Que tu playlist de Spotify sea publica",
    option_b: "Que tu historial de YouTube sea publico",
    category: "funny"
  },
  {
    option_a: "Que tu mama maneje tus redes sociales",
    option_b: "Que tu ex sea tu community manager",
    category: "funny"
  },
  {
    option_a: "Solo poder comunicarte con memes",
    option_b: "Solo poder comunicarte con emojis",
    category: "funny"
  },
  {
    option_a: "Que tu voz suene como ardilla siempre",
    option_b: "Que tu voz suene super grave como demonio",
    category: "funny"
  }
]

dilemmas.each do |dilemma|
  WouldYouRatherCard.find_or_create_by!(
    option_a: dilemma[:option_a],
    option_b: dilemma[:option_b]
  ) do |card|
    card.category = dilemma[:category]
  end
end

puts "Created #{WouldYouRatherCard.count} Would You Rather cards"
