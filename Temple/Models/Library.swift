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
        ExerciseSeed(name: "Elevaciones laterales", group: "Shoulders", equipment: "Dumbbells", tips: [
            "Inclina el torso unos 10–15° desde la cadera y mantén los codos levemente flexionados. Piensa en subir los codos, no las manos.",
            "Lleva las manos un poco por delante del cuerpo (plano de la escápula) en vez de totalmente a los lados: el deltoides medio trabaja mejor y el hombro sufre menos.",
            "Sube solo hasta la altura del hombro. Por encima entran los trapecios y pierdes el foco.",
            "Baja los hombros lejos de las orejas durante todo el movimiento; si te encoges, el peso es demasiado.",
            "Bajada lenta de 3 segundos. Si necesitas balanceo para subir, baja el peso."]),
        ExerciseSeed(name: "Fondos en paralelas", group: "Chest", equipment: "Parallel bars", tips: [
            "Pecho: inclina el torso 20–30° hacia delante y deja los codos algo abiertos. Tríceps: torso vertical y codos pegados.",
            "Hombros abajo y atrás todo el recorrido; si ruedan hacia delante en el fondo, estás cargando la articulación en vez del músculo.",
            "Baja hasta que el brazo quede paralelo al suelo o apenas por debajo, y solo hasta donde el hombro esté cómodo.",
            "Piernas ligeramente atrás y tobillos cruzados, abdomen firme. Sin balanceo.",
            "Sube extendiendo sin encogerte: el cuello largo, los hombros lejos de las orejas."]),
        ExerciseSeed(name: "Press de banca plano", group: "Chest", equipment: "Dumbbells, bench", tips: [
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
        ExerciseSeed(name: "Curl martillo de pie", group: "Arms", equipment: "Dumbbells", tips: [
            "Codos pegados a los costados y quietos: si se adelantan, el hombro hace el trabajo.",
            "Agarre neutro (palmas enfrentadas) y muñecas rectas. Aquí trabajan el braquial y el braquiorradial, que dan grosor al brazo.",
            "Glúteos apretados y torso quieto. Sin balanceo: si lo necesitas, baja el peso.",
            "Sube hasta que el antebrazo esté vertical y aprieta un segundo arriba.",
            "Baja en 3 segundos hasta la extensión completa."]),
        ExerciseSeed(name: "Sentadilla búlgara", group: "Legs", equipment: "Bench, dumbbells", tips: [
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
    ]
}
