enum GameType {
  wordBomb,
  impostor,
  threeInFive,
  soundChain,
  taboo,
  truthOrDare,
}

class GameInfo {
  final GameType type;
  final String name;
  final String emoji;
  final int minPlayers;
  final int maxPlayers;
  final String description;
  final List<String> howToPlay;
  final String? imagePath;

  const GameInfo({
    required this.type,
    required this.name,
    required this.emoji,
    required this.minPlayers,
    required this.maxPlayers,
    this.description = '',
    this.howToPlay = const [],
    this.imagePath,
  });

  static const List<GameInfo> allGames = [
    GameInfo(
      type: GameType.wordBomb,
      name: 'Word Bomb',
      emoji: '\u{1F4A3}',
      minPlayers: 2,
      maxPlayers: 10,
      description: 'Di una palabra antes de que explote la bomba',
      imagePath: 'assets/imagenes/WordBomb.webp',
      howToPlay: [
        'Aparece una silaba o categoria en pantalla',
        'Di una palabra que la contenga y pasa al siguiente',
        'La bomba tiene un timer oculto aleatorio',
        'Si explota en tu turno, pierdes una vida',
        'El ultimo jugador en pie gana!',
      ],
    ),
    GameInfo(
      type: GameType.impostor,
      name: 'El Impostor',
      emoji: '\u{1F575}\u{FE0F}',
      minPlayers: 3,
      maxPlayers: 10,
      description: 'Descubre quien es el impostor del grupo',
      imagePath: 'assets/imagenes/Impostor.webp',
      howToPlay: [
        'Todos reciben una palabra secreta excepto el impostor',
        'El impostor recibe una palabra diferente',
        'Por turnos, cada jugador da una pista sobre su palabra',
        'Debatan y voten por quien creen que es el impostor',
        'Si aciertan, ganan los jugadores. Si no, gana el impostor!',
      ],
    ),
    GameInfo(
      type: GameType.threeInFive,
      name: '3 en 5',
      emoji: '\u{26A1}',
      minPlayers: 2,
      maxPlayers: 10,
      description: 'Nombra 3 cosas en 5 segundos',
      imagePath: 'assets/imagenes/TresEnCinco.webp',
      howToPlay: [
        'Aparece una categoria (ej: "3 frutas rojas")',
        'Tienes solo 5 segundos para decir 3 respuestas',
        'Los demas jugadores deciden si son validas',
        'Si lo logras, ganas un punto!',
        'Gana quien tenga mas puntos al final',
      ],
    ),
    GameInfo(
      type: GameType.soundChain,
      name: 'Sound Chain',
      emoji: '\u{1F50A}',
      minPlayers: 3,
      maxPlayers: 10,
      description: 'Memoriza y repite la cadena de sonidos',
      imagePath: 'assets/imagenes/SoundChain.webp',
      howToPlay: [
        'Se muestra una lista de sonidos de animales numerados',
        'Todos tienen unos segundos para memorizarlos',
        'La lista desaparece y aparece un numero',
        'Di el sonido correcto para ese numero y pasa',
        'Si fallas o la bomba explota, pierdes una vida!',
      ],
    ),
    GameInfo(
      type: GameType.taboo,
      name: 'Tabu Express',
      emoji: '\u{1F6AB}',
      minPlayers: 4,
      maxPlayers: 10,
      description: 'Describe sin usar las palabras prohibidas',
      imagePath: 'assets/imagenes/TabuExpress.webp',
      howToPlay: [
        'Aparece una palabra que debes hacer adivinar',
        'Debajo hay palabras PROHIBIDAS que no puedes decir',
        'Describe la palabra sin usar las prohibidas',
        'Los demas vigilan que no digas las palabras tabu',
        'Consigue el mayor puntaje antes de que se acabe el tiempo!',
      ],
    ),
    GameInfo(
      type: GameType.truthOrDare,
      name: 'Verdad o Reto',
      emoji: '\u{1F525}',
      minPlayers: 2,
      maxPlayers: 10,
      description: 'Verdad o reto, tu decides',
      imagePath: 'assets/imagenes/VerdadOReto.webp',
      howToPlay: [
        'Elige entre Verdad o Reto',
        'Si eliges verdad, debes responder honestamente',
        'Si eliges reto, debes cumplir el desafio',
        'Si cumples, ganas un punto. Si no, pierdes!',
        'Ajusta la intensidad: suave, picante o extremo',
      ],
    ),
  ];
}
