import Foundation

struct ExerciseSeed {
    let name: String
    let group: String
    let equipment: String
    var timed = false
    var art: String? = nil          // asset name of the illustration
    let tips: [String]
}

/// The preloaded exercise library. Weights and reps always start at zero; the user fills them in.
enum Library {
    static let all: [ExerciseSeed] = [
        ExerciseSeed(name: "Press militar con mancuernas", group: "Shoulders", equipment: "Dumbbells", art: "press-militar", tips: [
            "Costillas abajo y glúteos apretados: el torso queda rígido y la zona lumbar no se arquea. Si te arqueas, estás compensando con la espalda lo que debería hacer el hombro.",
            "Arranca con las mancuernas a la altura de las orejas, antebrazos verticales y codos ligeramente por delante del torso (unos 30°), no abiertos a 90°. Es el plano natural de la escápula y cuida el manguito rotador.",
            "Empuja arriba y un poco hacia adentro, en arco, hasta que los bíceps queden junto a las orejas. Frena antes de bloquear los codos para mantener la tensión en el deltoides.",
            "Baja en 2–3 segundos hasta justo por debajo de la altura de la oreja. Si rebotas abajo, estás usando el rebote y no el músculo.",
            "Muñecas apiladas sobre los codos; no dejes que las mancuernas se vayan hacia atrás de la cabeza."]),
        ExerciseSeed(name: "Elevaciones laterales", group: "Shoulders", equipment: "Dumbbells", art: "elevaciones-laterales", tips: [
            "Inclina el torso unos 10–15° desde la cadera y mantén los codos levemente flexionados. Piensa en subir los codos, no las manos.",
            "Lleva las manos un poco por delante del cuerpo (plano de la escápula) en vez de totalmente a los lados: el deltoides medio trabaja mejor y el hombro sufre menos.",
            "Sube solo hasta la altura del hombro. Por encima entran los trapecios y pierdes el foco.",
            "Baja los hombros lejos de las orejas durante todo el movimiento; si te encoges, el peso es demasiado.",
            "Bajada lenta de 3 segundos. Si necesitas balanceo para subir, baja el peso."]),
        ExerciseSeed(name: "Fondos en barra recta", group: "Chest", equipment: "Single bar", tips: [
            "Agarra una sola barra a la altura de la cintura o el pecho bajo, manos un poco más anchas que las caderas, brazos estirados y hombros hacia abajo (sin encogerlos).",
            "Inclina el torso hacia adelante y flexiona las rodillas hacia atrás, cruzando los tobillos, para que las piernas no choquen con el suelo ni con la barra.",
            "Baja con control llevando el pecho hacia la barra, con los codos hacia atrás y cerca del cuerpo, hasta que los hombros queden cerca de la altura de los codos. No te dejes caer.",
            "Empuja con las palmas hasta extender los codos sin bloquearlos de golpe; mantén el abdomen firme para que el cuerpo no se balancee.",
            "Si el hombro molesta, acorta el recorrido o sube la barra."]),
        ExerciseSeed(name: "Fondos en paralelas", group: "Chest", equipment: "Parallel bars", art: "fondos-en-paralelas", tips: [
            "Pecho: inclina el torso 20–30° hacia delante y deja los codos algo abiertos. Tríceps: torso vertical y codos pegados.",
            "Hombros abajo y atrás todo el recorrido; si ruedan hacia delante en el fondo, estás cargando la articulación en vez del músculo.",
            "Baja hasta que el brazo quede paralelo al suelo o apenas por debajo, y solo hasta donde el hombro esté cómodo.",
            "Piernas ligeramente atrás y tobillos cruzados, abdomen firme. Sin balanceo.",
            "Sube extendiendo sin encogerte: el cuello largo, los hombros lejos de las orejas."]),
        ExerciseSeed(name: "Press de banca plano con mancuernas", group: "Chest", equipment: "Dumbbells, bench", art: "press-de-banca-con-mancuernas", tips: [
            "Junta y baja las escápulas contra el banco antes de empezar y no las sueltes en toda la serie. Un arco leve y los pies firmes en el suelo.",
            "Abajo, antebrazos verticales y codos a 45–60° del torso, nunca a 90°: el pecho trabaja más y el hombro sufre menos.",
            "Baja las mancuernas a los lados del pecho hasta sentir el estiramiento, y empuja arriba y un poco hacia adentro.",
            "No choques las mancuernas arriba; detente con el pecho aún en tensión.",
            "Controla la bajada en 2–3 segundos. El pecho crece en el recorrido negativo."]),
        ExerciseSeed(name: "Dominadas supinas", group: "Back", equipment: "Pull-up bar", art: "dominadas-supinas", tips: [
            "Empieza desde colgado activo: baja las escápulas (alejándolas de las orejas) antes de doblar los codos. Es lo que activa el dorsal en vez del bíceps solo.",
            "Agarre supino al ancho de hombros. Lleva los codos hacia abajo y un poco atrás, hacia los bolsillos traseros.",
            "Sube el pecho hacia la barra, no la barbilla. Piernas ligeramente por delante, glúteos y abdomen apretados.",
            "Baja hasta colgarte de nuevo, controlado y sin balanceo (nada de kipping).",
            "No estires el cuello hacia la barra: la cabeza en línea con la columna."]),
        ExerciseSeed(name: "Sentadilla búlgara", group: "Legs", equipment: "Bench, dumbbells", art: "sentadilla-bulgara", tips: [
            "El pie de atrás apoyado en el banco solo como soporte; casi todo el peso va en la pierna delantera.",
            "Coloca el pie delantero lo bastante lejos para que la espinilla quede casi vertical al bajar. Muy cerca carga la rodilla; muy lejos, el pie de atrás.",
            "Torso algo inclinado para trabajar más el glúteo; más vertical para más cuádriceps.",
            "Empuja con el medio del pie y el talón delantero. La rodilla sigue la línea de los dedos del pie.",
            "Baja recto, sin balancearte hacia los lados, hasta que el muslo quede paralelo o más abajo."]),
        ExerciseSeed(name: "Hollow body hold", group: "Core", equipment: "None", timed: true, art: "hollow-body-hold", tips: [
            "La zona lumbar pegada al suelo y las costillas abajo (pelvis en retroversión). Si la espalda se despega, sube las piernas más alto.",
            "Brazos junto a las orejas, piernas juntas y estiradas, puntas de pie estiradas, hombros despegados del suelo y mentón apenas recogido.",
            "Aprieta cuádriceps y glúteos como si fueras una sola pieza rígida; respira corto sin soltar las costillas.",
            "Para progresar sin perder la forma: rodillas flexionadas o brazos a los costados; luego cuerpo completo."]),
        ExerciseSeed(name: "Curl martillo sentado con banco inclinado", group: "Arms", equipment: "Dumbbells, incline bench", art: "curl-martillo-inclinado", tips: [
            "Espalda y hombros pegados al respaldo inclinado; los brazos cuelgan detrás de la línea del torso, lo que estira el bíceps largo y el braquial.",
            "Codos quietos y apuntando al suelo: si se adelantan, el hombro roba el trabajo.",
            "Agarre neutro, muñecas rectas. Sube sin balanceo hasta que el antebrazo quede vertical.",
            "Baja en 3 segundos hasta extender por completo; el estiramiento abajo es lo que hace útil este ejercicio."]),
        ExerciseSeed(name: "Pájaros (deltoides posterior)", group: "Shoulders", equipment: "Dumbbells", art: "pajaros", tips: [
            "Torso casi paralelo al suelo, espalda neutra y cuello largo; la mirada al suelo.",
            "Codos levemente flexionados y abiertos: piensa en separar los codos, no en subir las manos.",
            "Sube hasta la línea del torso y aprieta las escápulas apenas al final; sin encogerte con los trapecios.",
            "Peso ligero y bajada de 3 segundos: el deltoides posterior es pequeño y se compensa con facilidad."]),
        ExerciseSeed(name: "Curl de concentración tipo martillo", group: "Arms", equipment: "Dumbbell", art: "curl-concentracion-martillo", tips: [
            "Sentado, codo apoyado en la cara interna del muslo y el brazo colgando vertical.",
            "Agarre neutro (palma hacia el cuerpo); el antebrazo sube en un arco sin mover el hombro.",
            "Aprieta un segundo arriba y baja en 3 segundos hasta extender casi por completo.",
            "Torso quieto: si te inclinas para subir, el peso es excesivo."]),
        ExerciseSeed(name: "Flexiones de brazos", group: "Chest", equipment: "Bodyweight", art: "flexiones-de-brazos", tips: [
            "Cuerpo en una sola línea, de cabeza a talones: glúteos y abdomen apretados, sin hundir la cadera.",
            "Manos algo más anchas que los hombros, codos a unos 45° del torso, nunca abiertos a 90°.",
            "Baja hasta que el pecho roce casi el suelo; empuja el suelo alejándolo, abriendo bien las escápulas arriba.",
            "Mirada ligeramente adelantada, cuello neutro."]),
        ExerciseSeed(name: "Extensión de tríceps por encima de la cabeza con una mancuerna", group: "Arms", equipment: "Dumbbell", art: "extension-triceps-sobre-la-cabeza", tips: [
            "Codos apuntando al techo y cerca de las orejas; solo se mueve el antebrazo.",
            "Costillas abajo y glúteos apretados para que la zona lumbar no se arquee.",
            "Baja hasta sentir el estiramiento profundo del tríceps y extiende sin bloquear de golpe.",
            "Sostén la mancuerna con ambas manos bajo la cabeza de la pesa, muñecas rectas."]),
        ExerciseSeed(name: "Fondos en banco", group: "Arms", equipment: "Bench", art: "fondos-en-banco", tips: [
            "Manos junto a la cadera, dedos hacia delante, y la espalda muy pegada al banco.",
            "Hombros abajo y atrás: si se adelantan en el fondo, la articulación sufre.",
            "Baja solo hasta unos 90° de codo; más profundo carga el hombro.",
            "Codos apuntando atrás, no a los lados. Cuanto más extiendas las piernas, más difícil."]),
        ExerciseSeed(name: "Dominadas con agarre paralelo/neutro", group: "Back", equipment: "Pull-up bar, neutral handles", art: "dominadas-neutras", tips: [
            "Arranca desde colgado activo: baja las escápulas antes de doblar los codos.",
            "Codos hacia abajo y atrás, rozando los costados; es el agarre más amable con hombros y codos.",
            "Sube el pecho hacia las manos, glúteos y abdomen firmes, sin balanceo.",
            "Baja controlado hasta la extensión completa."]),
        ExerciseSeed(name: "Sentadilla sumo con pesa rusa", group: "Legs", equipment: "Kettlebell", art: "sentadilla-sumo-pesa-rusa", tips: [
            "Pies más anchos que los hombros con puntas hacia afuera; las rodillas siguen la dirección de los pies.",
            "Torso erguido, pesa colgando entre las piernas, pecho alto.",
            "Baja hasta que los muslos queden paralelos; empuja el suelo hacia afuera para activar glúteos y aductores.",
            "Aprieta glúteos arriba sin hiperextender la zona lumbar."]),
        ExerciseSeed(name: "Elevaciones de gemelos con mancuernas", group: "Legs", equipment: "Dumbbells", art: "elevaciones-de-gemelos", tips: [
            "Apoya la parte delantera del pie en un escalón si puedes y baja el talón por debajo para estirar.",
            "Sube lo más alto posible sobre la punta y aguanta un segundo arriba.",
            "Rodillas casi extendidas, sin rebotar; la subida es lenta.",
            "Pies paralelos o levemente abiertos; pesa solo lo que permita rango completo."]),
        ExerciseSeed(name: "Zancadas caminando con mancuernas", group: "Legs", equipment: "Dumbbells", art: "zancadas-caminando", tips: [
            "Paso largo para que, abajo, ambas rodillas formen unos 90° y la espinilla delantera quede casi vertical.",
            "Torso erguido, abdomen firme, mancuernas a los lados sin balancearse.",
            "Empuja con el talón delantero; la rodilla de atrás casi roza el suelo.",
            "Un poco de inclinación hacia delante carga más el glúteo."]),
        ExerciseSeed(name: "Encogimientos de hombros con mancuernas", group: "Shoulders", equipment: "Dumbbells", art: "encogimientos-de-hombros", tips: [
            "Sube los hombros recto hacia las orejas; sin rotarlos hacia delante ni hacia atrás.",
            "Aguanta un segundo arriba y baja lento hasta el estiramiento completo.",
            "Brazos relajados y estirados, cuello largo, mirada al frente.",
            "No uses impulso con las piernas."]),
        ExerciseSeed(name: "Remo con mancuerna a un brazo", group: "Back", equipment: "Dumbbell, bench", art: "remo-a-un-brazo", tips: [
            "Espalda plana y paralela al suelo, mano y rodilla de apoyo en el banco.",
            "Tira el codo hacia la cadera, no hacia el techo; imagina guardar la mancuerna en el bolsillo trasero.",
            "Aprieta el dorsal arriba un segundo y baja hasta estirar el hombro sin rotar el torso.",
            "Caderas cuadradas: sin girar el tronco para ayudarte."]),
        ExerciseSeed(name: "Elevaciones frontales", group: "Shoulders", equipment: "Dumbbells", art: "elevaciones-frontales", tips: [
            "Brazos casi rectos, sube hasta la altura de los hombros; no más.",
            "Torso quieto, sin inclinarte hacia atrás para subir.",
            "Agarre neutro o pronado, el que sientas mejor en el hombro.",
            "Baja en 3 segundos sin soltar la tensión."]),
        ExerciseSeed(name: "Pike push-ups", group: "Shoulders", equipment: "Bodyweight", art: "pike-push-ups", tips: [
            "Cadera alta, formando una V invertida; manos algo más anchas que los hombros.",
            "Baja la cabeza hacia el suelo entre las manos, no hacia delante.",
            "Codos a unos 45° del torso, sin abrirlos.",
            "Empuja hasta extender sin encoger los hombros; cuanto más verticales, más trabaja el hombro."]),
        ExerciseSeed(name: "Curl martillo cruzado", group: "Arms", equipment: "Dumbbells", art: "curl-martillo-cruzado", tips: [
            "Sube la mancuerna cruzando hacia el hombro contrario, con agarre neutro.",
            "Codo pegado al costado y quieto.",
            "Aprieta un segundo arriba y baja en 3 segundos.",
            "Alterna sin balanceo; el torso no se mueve."]),
        ExerciseSeed(name: "Australian pull-ups", group: "Back", equipment: "Low bar", art: "australian-pull-ups", tips: [
            "Cuerpo recto de cabeza a talones, glúteos apretados; cuanto más horizontal, más difícil.",
            "Tira del pecho hacia la barra, codos a unos 45°.",
            "Aprieta las escápulas arriba y baja controlado hasta extender los brazos.",
            "Sin hundir la cadera ni estirar el cuello."]),
        ExerciseSeed(name: "Flexiones declinadas", group: "Chest", equipment: "Bench", art: "flexiones-declinadas", tips: [
            "Pies sobre el banco, cuerpo en una línea recta.",
            "Cuanto más altos los pies, más trabaja el pecho superior y el hombro.",
            "Codos a unos 45° del torso.",
            "Abdomen y glúteos apretados; sin hundir la zona lumbar."]),
        ExerciseSeed(name: "Flexiones cerradas", group: "Chest", equipment: "Bodyweight", art: "flexiones-cerradas", tips: [
            "Manos juntas, a menos de un ancho de hombros, debajo del pecho; los codos rozan las costillas al bajar.",
            "Cuerpo recto de cabeza a talones, abdomen y glúteos firmes.",
            "Baja con control hasta casi tocar el suelo y empuja: trabaja más los tríceps que la flexión normal.",
            "Si la muñeca molesta, separa un poco las manos o apóyate en los puños."]),
        ExerciseSeed(name: "Skull crushers", group: "Arms", equipment: "Dumbbells, bench", art: "skull-crushers", tips: [
            "Codos apuntando al techo y quietos, algo más cerrados que los hombros.",
            "Baja las mancuernas hacia los lados de la cabeza, solo se mueve el antebrazo.",
            "Extiende sin bloquear de golpe.",
            "Peso controlable: el codo no perdona los excesos."]),
        ExerciseSeed(name: "Patada de tríceps", group: "Arms", equipment: "Dumbbell", art: "patada-de-triceps", tips: [
            "Torso casi paralelo al suelo, espalda neutra.",
            "Codo pegado al cuerpo y fijo, a la altura del torso.",
            "Extiende hasta que el brazo quede recto y aprieta un segundo.",
            "Baja lento; no balancees el hombro."]),
        ExerciseSeed(name: "Pullover con mancuerna", group: "Chest", equipment: "Dumbbell, bench", art: "pullover", tips: [
            "Mancuerna con ambas manos, brazos casi rectos, codos algo flexionados.",
            "Baja detrás de la cabeza hasta sentir el estiramiento del pecho y el dorsal.",
            "Costillas abajo, sin arquear la espalda.",
            "Sube con control en arco hasta sobre el pecho."]),
        ExerciseSeed(name: "Dominadas pronas", group: "Back", equipment: "Pull-up bar", art: "dominadas-pronas", tips: [
            "Agarre algo más ancho que los hombros; arranca desde colgado activo.",
            "Lleva los codos hacia abajo y atrás.",
            "Sube el pecho hacia la barra, sin balanceo.",
            "Baja hasta extender por completo."]),
        ExerciseSeed(name: "Sentadilla goblet", group: "Legs", equipment: "Dumbbell", art: "sentadilla-goblet", tips: [
            "Mancuerna pegada al pecho, codos hacia dentro.",
            "Pies algo más anchos que los hombros, puntas ligeramente abiertas.",
            "Baja con el torso erguido; los codos pueden rozar el interior de las rodillas.",
            "Empuja el suelo y aprieta los glúteos arriba."]),
        ExerciseSeed(name: "Step-ups", group: "Legs", equipment: "Step, dumbbells", art: "step-ups", tips: [
            "Todo el pie sobre el escalón; empuja con el talón de la pierna que sube.",
            "Sube controlado sin impulsarte con la pierna de atrás.",
            "Torso erguido, abdomen firme.",
            "Baja lento, también controlando la pierna de atrás."]),
        ExerciseSeed(name: "Puente de glúteos", group: "Legs", equipment: "Bodyweight", art: "puente-de-gluteos", tips: [
            "Pies cerca de los glúteos, rodillas en línea con los pies.",
            "Empuja con los talones y sube la cadera hasta formar una línea hombro–rodilla.",
            "Aprieta fuerte los glúteos arriba un segundo; sin arquear la zona lumbar.",
            "Costillas abajo, mentón recogido."]),
        ExerciseSeed(name: "Elevaciones de rodillas colgado", group: "Core", equipment: "Pull-up bar", art: "elevaciones-de-rodillas-colgado", tips: [
            "Cuelga con hombros activos, sin encogerlos.",
            "Sube las rodillas curvando la pelvis hacia las costillas: eso trabaja el abdomen.",
            "Evita el balanceo; sube y baja controlado.",
            "Exhala arriba, aprieta un segundo."]),
        ExerciseSeed(name: "Plancha lateral", group: "Core", equipment: "Bodyweight", art: "plancha-lateral", tips: [
            "Codo bajo el hombro; cuerpo en una sola línea de cabeza a pies.",
            "Empuja el suelo con el antebrazo y sube la cadera.",
            "Pies apilados o uno delante del otro para más estabilidad.",
            "Respira normal; sin rotar el torso."]),
        ExerciseSeed(name: "Remo con pecho apoyado en máquina", group: "Back", equipment: "Machine", art: "remo-pecho-apoyado", tips: [
            "Ajusta el asiento para que el pecho quede firme contra el soporte y los brazos estirados lleguen a las asas sin encogerte.",
            "Inicia el movimiento llevando los hombros hacia atrás y abajo, y después tira con los codos hacia las costillas.",
            "Aprieta las escápulas un segundo al final; no te despegues del respaldo ni tires con el cuello.",
            "Vuelve en 2–3 segundos hasta estirar la espalda, sin soltar el peso de golpe."]),
        ExerciseSeed(name: "Crunch abdominal", group: "Core", equipment: "Bodyweight", art: "crunch-abdominal", tips: [
            "Rodillas flexionadas, pies apoyados y la zona lumbar relajada contra el suelo; manos cruzadas en el pecho o rozando las sienes.",
            "Sube solo las costillas hacia la pelvis, enrollando el torso; no tires del cuello con las manos.",
            "Exhala arriba y aprieta el abdomen un segundo; baja lento sin dejar caer la cabeza.",
            "El recorrido es corto: si te sientas del todo, trabaja el psoas y no el abdomen."]),
    ]
}
