# 🎮 BOOM! Party Games — Documento de Diseño Completo

## Para usar con Claude Code

> **INSTRUCCIÓN PARA CLAUDE CODE:** Este documento contiene TODAS las especificaciones para crear una app de party games en Flutter. Sigue cada sección al pie de la letra. No inventes ni asumas nada que no esté aquí. Si algo no está claro, pregunta antes de codear.

---

## 1. VISIÓN GENERAL DEL PRODUCTO

### Qué es
App móvil de juegos de fiesta/grupo. Un solo teléfono, se pasa entre jugadores. Sin internet requerido. Monetización con ads (Unity Ads).

### Nombre de la app
**BOOM! Party Games** (nombre de paquete: `com.boom.partygames`)

### Público objetivo
- Jóvenes 16-30 años, español como idioma principal
- Grupos de amigos en fiestas, reuniones, previas
- Mercado primario: España y Latinoamérica

### Modelo de negocio
- **Gratis** con ads (NO suscripción, NO compras in-app)
- Interstitial ads entre partidas (Unity Ads)
- Rewarded video ads para desbloquear categorías premium
- Ventaja competitiva vs Picoboom: sin paywall de suscripción

### Competencia directa
| App | Descargas | Debilidades |
|-----|-----------|-------------|
| Picoboom | 77K (380/día) | Suscripción semanal, carga lenta, contenido limitado |
| Splash Party Games | 1M+ | Genérica, no enfocada en español |
| JKLM.fun (web) | Popular | Solo web, sin app móvil, solo inglés |

### Diferenciadores clave
1. **Word Bomb** como juego estrella (casi NO existe en móvil)
2. Sin suscripción — todo gratis con ads
3. Contenido en español nativo (no traducido)
4. Más contenido que Picoboom desde el día 1

---

## 2. STACK TÉCNICO

### Framework
**Flutter** (última versión estable)

### Dependencias principales
```yaml
dependencies:
  flutter:
    sdk: flutter
  unity_ads_plugin: ^latest  # Unity Ads SDK
  audioplayers: ^latest       # Sonidos y efectos
  vibration: ^latest          # Haptic feedback
  shared_preferences: ^latest # Guardar configuración local
  google_fonts: ^latest       # Tipografía
  animated_text_kit: ^latest  # Animaciones de texto
  confetti: ^latest           # Efecto confetti/celebración
  flutter_animate: ^latest    # Animaciones fluidas
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_launcher_icons: ^latest
```

### Estructura de archivos
```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── theme.dart           # Colores, tipografía, estilos
│   ├── constants.dart       # Constantes globales
│   └── ads_config.dart      # IDs de Unity Ads
├── models/
│   ├── player.dart          # Modelo de jugador
│   ├── game_config.dart     # Configuración de partida
│   └── game_result.dart     # Resultados/penalizaciones
├── screens/
│   ├── home_screen.dart     # Pantalla principal
│   ├── player_setup_screen.dart  # Añadir nombres
│   ├── game_selector_screen.dart # Elegir minijuego
│   ├── settings_screen.dart      # Ajustes
│   ├── games/
│   │   ├── word_bomb_screen.dart
│   │   ├── impostor_screen.dart
│   │   ├── three_in_five_screen.dart
│   │   ├── sound_chain_screen.dart
│   │   ├── taboo_screen.dart
│   │   └── truth_or_dare_screen.dart
│   └── results/
│       ├── bomb_exploded_screen.dart  # Pantalla explosión
│       ├── vote_screen.dart           # Votación (impostor)
│       └── scoreboard_screen.dart     # Marcador general
├── widgets/
│   ├── bomb_timer.dart       # Widget bomba con countdown
│   ├── player_card.dart      # Tarjeta de jugador
│   ├── game_card.dart        # Tarjeta de minijuego en selector
│   ├── penalty_wheel.dart    # Ruleta de castigos
│   └── animated_button.dart  # Botón con animación press
├── services/
│   ├── ads_service.dart      # Gestión Unity Ads
│   ├── audio_service.dart    # Gestión de sonidos
│   └── haptic_service.dart   # Gestión de vibración
├── data/
│   ├── word_bomb_data.dart       # Letras y restricciones
│   ├── impostor_data.dart        # Pares de palabras
│   ├── three_in_five_data.dart   # Categorías
│   ├── sound_chain_data.dart     # Sonidos y reglas
│   ├── taboo_data.dart           # Palabras + tabú
│   └── truth_or_dare_data.dart   # Preguntas y retos
└── utils/
    ├── timer_utils.dart
    └── random_utils.dart
```

### Plataforma objetivo
- Android (APK para Google Play)
- minSdkVersion: 21 (Android 5.0)
- targetSdkVersion: 34
- Orientación: Portrait only (forzado)

---

## 3. DISEÑO VISUAL Y UX

### Paleta de colores
```dart
// Fondo principal
static const Color background = Color(0xFF1A1A2E);      // Azul oscuro profundo
static const Color surface = Color(0xFF16213E);          // Azul oscuro medio
static const Color cardBackground = Color(0xFF0F3460);   // Azul medio

// Acentos
static const Color primary = Color(0xFFE94560);          // Rojo/rosa vibrante (bomba)
static const Color secondary = Color(0xFFFF6B35);        // Naranja energético
static const Color accent = Color(0xFF53D8FB);           // Cyan brillante
static const Color success = Color(0xFF00E676);          // Verde éxito
static const Color warning = Color(0xFFFFD93D);          // Amarillo advertencia

// Texto
static const Color textPrimary = Color(0xFFFFFFFF);
static const Color textSecondary = Color(0xFFB8C5D6);
```

### Tipografía
- Títulos: **Fredoka One** (Google Fonts) — redondeada, divertida, amigable
- Body: **Nunito** (Google Fonts) — legible, moderna
- Números/timer: **Orbitron** — digital/futurista para countdowns

### Estilo visual
- Dark theme SIEMPRE (mejor para fiestas/noche)
- Esquinas redondeadas (borderRadius: 20)
- Glassmorphism sutil en tarjetas (blur + opacity)
- Sombras de color (no negras, sino del color del elemento)
- Animaciones: bouncy, spring, nada lineal
- Iconos: emojis grandes como iconos de los juegos

### Reglas UX obligatorias
1. **Máximo 2 taps para empezar a jugar** (home → elegir juego → ya jugando)
2. **Botones grandes** — mínimo 56dp de alto, mejor 64dp
3. **Texto grande** — mínimo 18sp para body, 32sp+ para elementos de juego
4. **Feedback en cada tap** — vibración corta + sonido + animación visual
5. **No scroll** — todo el contenido visible sin scroll en cada pantalla
6. **Orientación portrait bloqueada**

---

## 4. FLUJO DE NAVEGACIÓN

```
[Splash Screen - 1.5s con logo]
        ↓
[HOME SCREEN]
  ├── Botón: "🎮 JUGAR" (grande, centro)
  ├── Botón: "⚙️ Ajustes" (esquina superior derecha)
  └── Texto: "BOOM! Party Games" + versión
        ↓ (tap JUGAR)
[PLAYER SETUP]
  ├── Lista de jugadores (min 2, max 10)
  ├── Campo input "Nombre del jugador"
  ├── Botón "+" para añadir
  ├── Swipe para eliminar jugador
  ├── Botón: "SIGUIENTE →"
  └── Los nombres se guardan en SharedPreferences para la próxima vez
        ↓
[GAME SELECTOR] ← También accesible al terminar cada partida
  ├── Grid de juegos (2 columnas)
  │   ├── 💣 Word Bomb
  │   ├── 🕵️ El Impostor
  │   ├── ⚡ 3 en 5
  │   ├── 🔊 Sound Chain
  │   ├── 🚫 Tabú Express
  │   └── 🔥 Verdad o Reto
  ├── Cada tarjeta muestra: emoji + nombre + "2-10 jugadores"
  └── Tap en juego → PANTALLA DEL JUEGO
        ↓
[PANTALLA DE JUEGO] (varía por juego)
        ↓ (al terminar ronda)
[RESULTADO] → Ad interstitial (cada 3 rondas) → [GAME SELECTOR]
```

### Cuándo mostrar ads
| Evento | Tipo de ad | Frecuencia |
|--------|-----------|------------|
| Después de cada 3 rondas | Interstitial | 1 de cada 3 rondas |
| Desbloquear categoría premium | Rewarded Video | Cuando el usuario elige |
| Primer uso | Ninguno | Las primeras 5 rondas son sin ads |

---

## 5. PANTALLAS DETALLADAS

### 5.1 Splash Screen
- Duración: 1.5 segundos
- Fondo: `background` color
- Centro: emoji 💣 grande (96px) con animación de "pulse"
- Debajo: "BOOM!" con animación fade-in
- Transición: fade out → home screen
- Precarga de Unity Ads durante splash

### 5.2 Home Screen
```
┌─────────────────────────┐
│            ⚙️            │  ← settings icon (top right)
│                         │
│                         │
│         💣              │  ← Emoji bomba 120px, animación bounce
│                         │
│   BOOM! Party Games     │  ← Fredoka One, 36sp, blanco
│                         │
│   ┌─────────────────┐   │
│   │   🎮 ¡JUGAR!    │   │  ← Botón principal, rojo, 64dp alto
│   └─────────────────┘   │
│                         │
│                         │
│   v1.0.0                │  ← versión, textSecondary, 14sp
└─────────────────────────┘
```

### 5.3 Player Setup Screen
```
┌─────────────────────────┐
│  ←  Jugadores (3/10)    │  ← Back arrow + counter
│                         │
│  ┌───────────────┬───┐  │
│  │ Nombre...     │ + │  │  ← Input + botón añadir
│  └───────────────┴───┘  │
│                         │
│  ┌─────────────────┐ ✕  │  ← Card jugador 1 + delete
│  │ 😎 Jesús        │    │
│  └─────────────────┘    │
│  ┌─────────────────┐ ✕  │
│  │ 🤪 María        │    │
│  └─────────────────┘    │
│  ┌─────────────────┐ ✕  │
│  │ 😂 Carlos       │    │
│  └─────────────────┘    │
│                         │
│  ┌─────────────────────┐│
│  │  SIGUIENTE →         ││  ← Habilitado con min 2 jugadores
│  └─────────────────────┘│
└─────────────────────────┘
```
- Emoji aleatorio asignado a cada jugador (de un set de ~20 emojis divertidos)
- Los nombres se persisten en SharedPreferences
- Al volver, los jugadores anteriores siguen ahí

### 5.4 Game Selector Screen
```
┌─────────────────────────┐
│  ←  Elige un juego      │
│                         │
│  ┌──────────┐ ┌──────────┐
│  │ 💣       │ │ 🕵️       │
│  │Word Bomb │ │Impostor  │
│  │ 2-10     │ │ 3-10     │
│  └──────────┘ └──────────┘
│  ┌──────────┐ ┌──────────┐
│  │ ⚡       │ │ 🔊       │
│  │ 3 en 5   │ │Sound     │
│  │ 2-10     │ │Chain 3-10│
│  └──────────┘ └──────────┘
│  ┌──────────┐ ┌──────────┐
│  │ 🚫       │ │ 🔥       │
│  │ Tabú     │ │Verdad o  │
│  │Express   │ │Reto 2-10 │
│  │ 4-10     │ │          │
│  └──────────┘ └──────────┘
└─────────────────────────┘
```
- Cards con glassmorphism
- Animación scale al hacer tap
- Si no hay suficientes jugadores para un juego, aparece un tooltip: "Necesitas X jugadores"

---

## 6. MINIJUEGOS — ESPECIFICACIONES DETALLADAS

---

### 6.1 💣 WORD BOMB (Bomba de Palabras)

**Inspirado en:** JKLM.fun / Bomb Party
**Jugadores:** 2-10
**Este es el juego DIFERENCIADOR — no existe en móvil**

#### Mecánica
1. Se muestra una **restricción de letras** en el centro de la pantalla (ej: "Empieza por M y termina en A")
2. Se muestra el nombre del jugador actual
3. Hay una **bomba con countdown** (timer aleatorio entre 8-20 segundos, NO visible al jugador — solo la bomba "latiendo" cada vez más rápido)
4. El jugador dice en voz alta una palabra que cumpla la restricción
5. Los otros jugadores validan (no hay validación automática — es juego social)
6. El jugador pulsa el botón **"PASO ✓"** para pasar al siguiente
7. Si el timer llega a 0 → **💥 EXPLOSIÓN** — ese jugador pierde la ronda
8. Siguiente ronda con nueva restricción

#### Tipos de restricciones (pool de ~100)
```dart
const wordBombChallenges = [
  // Empieza por + termina en
  {"type": "starts_ends", "start": "M", "end": "A", "display": "Empieza por M, termina en A"},
  {"type": "starts_ends", "start": "C", "end": "O", "display": "Empieza por C, termina en O"},
  {"type": "starts_ends", "start": "P", "end": "E", "display": "Empieza por P, termina en E"},
  {"type": "starts_ends", "start": "T", "end": "R", "display": "Empieza por T, termina en R"},
  {"type": "starts_ends", "start": "S", "end": "N", "display": "Empieza por S, termina en N"},
  
  // Contiene sílaba
  {"type": "contains", "syllable": "BRA", "display": "Contiene BRA"},
  {"type": "contains", "syllable": "TRO", "display": "Contiene TRO"},
  {"type": "contains", "syllable": "PLA", "display": "Contiene PLA"},
  {"type": "contains", "syllable": "GRE", "display": "Contiene GRE"},
  {"type": "contains", "syllable": "FLO", "display": "Contiene FLO"},
  {"type": "contains", "syllable": "CRU", "display": "Contiene CRU"},
  {"type": "contains", "syllable": "PRE", "display": "Contiene PRE"},
  {"type": "contains", "syllable": "TER", "display": "Contiene TER"},
  {"type": "contains", "syllable": "MAN", "display": "Contiene MAN"},
  {"type": "contains", "syllable": "LUZ", "display": "Contiene LUZ"},
  
  // Empieza por
  {"type": "starts", "letter": "Z", "display": "Empieza por Z"},
  {"type": "starts", "letter": "X", "display": "Empieza por X"},
  {"type": "starts", "letter": "Ñ", "display": "Empieza por Ñ"},
  {"type": "starts", "letter": "QU", "display": "Empieza por QU"},
  {"type": "starts", "letter": "CH", "display": "Empieza por CH"},
  
  // Número de sílabas
  {"type": "syllables", "count": 4, "display": "Exactamente 4 sílabas"},
  {"type": "syllables", "count": 5, "display": "Exactamente 5 sílabas"},
  
  // Categoría + letra
  {"type": "category_letter", "category": "Animal", "letter": "P", "display": "Animal que empieza por P"},
  {"type": "category_letter", "category": "País", "letter": "A", "display": "País que empieza por A"},
  {"type": "category_letter", "category": "Comida", "letter": "C", "display": "Comida que empieza por C"},
  {"type": "category_letter", "category": "Ciudad", "letter": "B", "display": "Ciudad que empieza por B"},
  {"type": "category_letter", "category": "Nombre propio", "letter": "L", "display": "Nombre que empieza por L"},
];
// GENERAR AL MENOS 100 RESTRICCIONES VARIADAS SIGUIENDO ESTOS PATRONES
```

#### Pantalla de juego Word Bomb
```
┌─────────────────────────┐
│  Ronda 3     Vidas: ❤️❤️  │
│                         │
│     😎 JESÚS            │  ← nombre grande, con emoji
│                         │
│  ┌─────────────────┐    │
│  │                 │    │
│  │ Empieza por M   │    │  ← La restricción, texto grande 28sp
│  │ Termina en A    │    │
│  │                 │    │
│  └─────────────────┘    │
│                         │
│        💣               │  ← Bomba animada (pulse cada vez más rápido)
│     ████████░░          │  ← Mecha que se va consumiendo (visual)
│                         │
│  ┌─────────────────────┐│
│  │    PASO ✓            ││  ← Botón verde grande, pasa al siguiente
│  └─────────────────────┘│
└─────────────────────────┘
```

#### Pantalla de explosión
```
┌─────────────────────────┐
│                         │
│                         │
│        💥               │  ← Emoji 120px con animación shake + scale
│                         │
│  ¡BOOM!                 │  ← Texto rojo grande, shake
│                         │
│  😎 Jesús perdió        │
│                         │
│  "La bomba explotó"     │  ← Mensaje random divertido
│                         │
│  ┌─────────────────────┐│
│  │  SIGUIENTE RONDA     ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │  CAMBIAR JUEGO       ││
│  └─────────────────────┘│
└─────────────────────────┘
```

#### Config del timer
- Timer aleatorio entre 8 y 20 segundos (el jugador NO ve los segundos)
- La bomba "late" (scale pulse animation):
  - >10s restantes: late cada 1.5s
  - 5-10s: late cada 0.8s
  - 3-5s: late cada 0.4s
  - <3s: late cada 0.15s (frenético)
- Vibración sync con el latido
- Al explotar: vibración larga (500ms), sonido explosión, pantalla shake

#### Sistema de vidas
- Cada jugador empieza con 3 vidas (❤️❤️❤️)
- Perder ronda = pierde 1 vida
- A 0 vidas → eliminado (queda como espectador)
- Último jugador en pie gana
- O bien: modo rápido sin vidas, simplemente pierde la ronda

---

### 6.2 🕵️ EL IMPOSTOR

**Inspirado en:** Spyfall / Splash "Impostor" / TikTok viral
**Jugadores:** 3-10

#### Mecánica
1. Se elige una **categoría** (Animales, Comida, Películas, etc.)
2. La app asigna una **palabra secreta** a todos los jugadores, EXCEPTO a 1 (el impostor)
3. Cada jugador ve su pantalla en privado (pasar teléfono tapando pantalla)
4. El impostor ve: "🕵️ ¡ERES EL IMPOSTOR! 🕵️" (sin saber la palabra)
5. Ronda de pistas: cada jugador dice UNA palabra relacionada en voz alta
6. Debate: el grupo discute quién creen que es el impostor
7. Votación en la app: cada jugador vota a quién sospecha
8. Resultado: se revela quién era el impostor

#### Flujo de pantallas

**Paso 1: Distribución de roles**
```
┌─────────────────────────┐
│                         │
│  Pasa el teléfono a:    │
│                         │
│     😎 JESÚS            │  ← nombre grande
│                         │
│  Toca para ver tu rol   │
│                         │
│  ┌─────────────────────┐│
│  │    👁️ VER ROL        ││  ← Al tocar, muestra durante 3s:
│  └─────────────────────┘│
│                         │
└─────────────────────────┘

→ Si NO es impostor:
┌─────────────────────────┐
│                         │
│   La palabra es:        │
│                         │
│   🐶 PERRO              │  ← grande, centro, 3 segundos
│                         │
│   ¡No la digas!         │
│                         │
│   [Auto-cierra en 3s]   │
└─────────────────────────┘

→ Si ES impostor:
┌─────────────────────────┐
│                         │
│   🕵️                    │
│                         │
│   ¡ERES EL              │
│    IMPOSTOR!            │  ← rojo, grande
│                         │
│   Categoría: Animales   │  ← solo ve la categoría, NO la palabra
│                         │
│   [Auto-cierra en 3s]   │
└─────────────────────────┘
```

**Paso 2: Ronda de pistas**
```
┌─────────────────────────┐
│  Ronda de pistas        │
│                         │
│  Turno de: 😎 Jesús     │
│                         │
│  Di UNA palabra         │
│  relacionada            │
│                         │
│  Categoría: Animales    │
│                         │
│  ┌─────────────────────┐│
│  │    SIGUIENTE ▶       ││
│  └─────────────────────┘│
└─────────────────────────┘
```

**Paso 3: Votación**
```
┌─────────────────────────┐
│  ¡A votar!              │
│  ¿Quién es el impostor? │
│                         │
│  Pasa el teléfono a:    │
│  😎 Jesús               │
│                         │
│  ┌─────────────────────┐│
│  │ 🤪 María             ││  ← botones con cada jugador
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │ 😂 Carlos            ││
│  └─────────────────────┘│
│  ┌─────────────────────┐│
│  │ 🤓 Ana               ││
│  └─────────────────────┘│
└─────────────────────────┘
```

**Paso 4: Resultado**
```
┌─────────────────────────┐
│                         │
│  El impostor era:       │
│                         │
│     🤪 MARÍA            │  ← reveal con animación
│                         │
│  La palabra era: PERRO  │
│                         │
│  Votos:                 │
│  María: 3 votos ✓       │
│  Carlos: 1 voto         │
│                         │
│  ¡El grupo GANÓ!        │  ← o "¡El impostor GANÓ!"
│                         │
│  ┌─────────────────────┐│
│  │  OTRA RONDA          ││
│  └─────────────────────┘│
└─────────────────────────┘
```

#### Base de datos de palabras (mínimo 30 por categoría, 10+ categorías)

```dart
const impostorData = {
  "Animales": ["Perro", "Gato", "Elefante", "León", "Delfín", "Águila", "Serpiente", "Oso", "Caballo", "Tiburón", "Conejo", "Pingüino", "Mono", "Lobo", "Jirafa", "Cocodrilo", "Tortuga", "Ratón", "Ballena", "Tigre", "Panda", "Zorro", "Canguro", "Pulpo", "Búho", "Cebra", "Rinoceronte", "Flamenco", "Camaleón", "Gorila"],
  
  "Comida": ["Pizza", "Hamburguesa", "Sushi", "Paella", "Tacos", "Helado", "Pasta", "Chocolate", "Ensalada", "Tortilla", "Ceviche", "Empanada", "Croissant", "Ramen", "Churros", "Nachos", "Gazpacho", "Croquetas", "Guacamole", "Brownie", "Falafel", "Kebab", "Lasaña", "Donut", "Pancakes", "Arepa", "Burrito", "Fondue", "Wok", "Curry"],
  
  "Películas": ["Titanic", "Avatar", "Matrix", "Jurassic Park", "Harry Potter", "El Padrino", "Star Wars", "Toy Story", "Frozen", "Batman", "Spider-Man", "Shrek", "Finding Nemo", "El Rey León", "Piratas del Caribe", "Gladiator", "Inception", "Avengers", "Indiana Jones", "Terminator", "Rocky", "Forrest Gump", "E.T.", "Jaws", "Alien", "Coco", "Up", "Wall-E", "Ratatouille", "Interestelar"],
  
  "Deportes": ["Fútbol", "Baloncesto", "Tenis", "Natación", "Boxeo", "Surf", "Esquí", "Golf", "Rugby", "Béisbol", "Voleibol", "Atletismo", "Ciclismo", "Karate", "Skateboarding", "Escalada", "Snowboard", "Paddle", "F1", "MotoGP", "Hockey", "Balonmano", "Esgrima", "Gimnasia", "Lucha", "Remo", "Vela", "Polo", "Cricket", "Dardos"],
  
  "Profesiones": ["Médico", "Bombero", "Policía", "Chef", "Piloto", "Astronauta", "Veterinario", "Arquitecto", "Abogado", "Profesor", "Dentista", "Periodista", "Fotógrafo", "DJ", "Electricista", "Fontanero", "Mecánico", "Panadero", "Cirujano", "Programador", "Cartero", "Jardinero", "Peluquero", "Granjero", "Pescador", "Bibliotecario", "Carpintero", "Enfermero", "Psicólogo", "Traductor"],
  
  "Lugares": ["Playa", "Hospital", "Aeropuerto", "Cine", "Supermercado", "Parque", "Biblioteca", "Gimnasio", "Restaurante", "Iglesia", "Zoo", "Museo", "Discoteca", "Estadio", "Universidad", "Gasolinera", "Farmacia", "Peluquería", "Cementerio", "Circo", "Casino", "Spa", "Montaña", "Volcán", "Desierto", "Cueva", "Cascada", "Isla", "Bosque", "Castillo"],
  
  "Países": ["España", "México", "Japón", "Brasil", "Italia", "Australia", "Egipto", "India", "Canadá", "Argentina", "Francia", "Alemania", "Rusia", "China", "Marruecos", "Colombia", "Perú", "Grecia", "Tailandia", "Noruega", "Cuba", "Portugal", "Chile", "Ecuador", "Turquía", "Suiza", "Holanda", "Irlanda", "Corea", "Sudáfrica"],
  
  "Marcas": ["Nike", "Apple", "McDonald's", "Coca-Cola", "Google", "Netflix", "Amazon", "Adidas", "Zara", "IKEA", "Disney", "Samsung", "PlayStation", "Ferrari", "Red Bull", "Starbucks", "Spotify", "YouTube", "WhatsApp", "Instagram", "TikTok", "Uber", "Tesla", "Lego", "Nintendo", "Mercedes", "BMW", "Gucci", "Rolex", "Puma"],
  
  "Personajes ficticios": ["Batman", "Pikachu", "Mario", "Shrek", "Elsa", "Goku", "Homer Simpson", "Bob Esponja", "Darth Vader", "Spiderman", "Mickey Mouse", "Superman", "Hulk", "Gandalf", "Woody", "Bugs Bunny", "Doraemon", "Naruto", "Cenicienta", "Peter Pan", "Aladdin", "Iron Man", "Thor", "Rapunzel", "Maléfica", "Yoda", "Harry Potter", "Hermione", "Thanos", "Deadpool"],
  
  "Instrumentos musicales": ["Guitarra", "Piano", "Batería", "Violín", "Flauta", "Trompeta", "Saxofón", "Bajo", "Arpa", "Ukelele", "Acordeón", "Clarinete", "Tuba", "Banjo", "Armónica", "Oboe", "Maracas", "Pandereta", "Xilófono", "Contrabajo", "Mandolina", "Gaita", "Órgano", "Bongos", "Djembé", "Triángulo", "Cajón", "Cello", "Teclado", "Castañuelas"],
  
  "Objetos cotidianos": ["Teléfono", "Llave", "Paraguas", "Reloj", "Gafas", "Billetera", "Mochila", "Cargador", "Espejo", "Almohada", "Toalla", "Cepillo", "Vela", "Tijeras", "Pegamento", "Destornillador", "Cuchara", "Sartén", "Nevera", "Microondas", "Aspiradora", "Plancha", "Lámpara", "Alfombra", "Cortina", "Despertador", "Cerradura", "Escalera", "Ventilador", "Enchufe"],
};
```

---

### 6.3 ⚡ 3 EN 5 (Name 3 in 5 seconds)

**Jugadores:** 2-10

#### Mecánica
1. Sale una **categoría** (ej: "Frutas rojas")
2. Timer visible de **5 segundos**
3. El jugador debe nombrar **3 cosas** de esa categoría en voz alta
4. Los demás validan (social, no automático)
5. Pulsa "LO LOGRÓ ✓" o "FALLÓ ✗"
6. Pasa al siguiente jugador con nueva categoría

#### Pantalla
```
┌─────────────────────────┐
│  3 en 5      😎 Jesús   │
│                         │
│  Nombra 3...            │
│                         │
│  ┌─────────────────┐    │
│  │                 │    │
│  │  FRUTAS ROJAS   │    │  ← Categoría grande
│  │                 │    │
│  └─────────────────┘    │
│                         │
│       ⏱️ 4              │  ← Countdown visible, grande, cambia color
│                         │
│  ┌──────────┐┌──────────┐│
│  │ ✓ LOGRÓ  ││ ✗ FALLÓ  ││
│  └──────────┘└──────────┘│
└─────────────────────────┘
```

Timer: 
- 5-4s: verde
- 3-2s: amarillo
- 1-0s: rojo + parpadeo
- Al llegar a 0: vibración + sonido buzzer

#### Base de datos de categorías (mínimo 150)
```dart
const threeInFiveCategories = [
  // Fáciles
  "Frutas amarillas",
  "Países de Europa",
  "Deportes con pelota",
  "Animales que vuelan",
  "Cosas que hay en un baño",
  "Marcas de coches",
  "Sabores de helado",
  "Partes del cuerpo",
  "Colores del arcoíris",
  "Instrumentos de cuerda",
  "Comidas italianas",
  "Superhéroes de Marvel",
  "Cosas que llevas en la playa",
  "Animales domésticos",
  "Flores",
  "Planetas del sistema solar",
  "Cosas pegajosas",
  "Meses con 31 días",
  "Tipos de pasta",
  "Ingredientes de una pizza",
  
  // Medias
  "Capitales de Latinoamérica",
  "Películas de Pixar",
  "Cosas que huelen mal",
  "Animales que empiezan por C",
  "Marcas de ropa deportiva",
  "Juegos de mesa",
  "Tipos de queso",
  "Bailes latinoamericanos",
  "Redes sociales",
  "Series de Netflix",
  "Cosas que dan miedo",
  "Excusas para llegar tarde",
  "Cosas que encuentras en un parque",
  "Comida que se come con las manos",
  "Profesiones que usan uniforme",
  "Cosas que brillan",
  "Animales del océano",
  "Frutas tropicales",
  "Cosas rojas",
  "Motivos para llorar",
  
  // Difíciles
  "Palabras que riman con gato",
  "Cosas que tienen ruedas pero NO son vehículos",
  "Famosos calvos",
  "Países que empiezan por I",
  "Cosas que haces antes de dormir",
  "Canciones con un color en el título",
  "Animales que empiezan por la letra de tu nombre",
  "Cosas que hay en el espacio",
  "Comidas que no existían hace 100 años",
  "Cosas que te ponen nervioso",
  "Palabras en inglés que todos usan",
  "Cosas que metes en una maleta",
  "Excusas para no ir a trabajar",
  "Cosas que haces en un ascensor",
  "Marcas que ya no existen",
  "Inventos del siglo XX",
  "Cosas que haces cuando estás aburrido",
  "Trabajos que no existirán en 20 años",
  "Cosas que tienen botones",
  "Motivos para sonreír",
  
  // ... GENERAR HASTA 150 CATEGORÍAS VARIADAS Y DIVERTIDAS
];
```

---

### 6.4 🔊 SOUND CHAIN (Cadena de Sonidos)

**Jugadores:** 3-10

#### Mecánica
1. Se asigna a cada **número del 1 al 10** un **sonido de animal** (aleatorio cada ronda)
2. Se muestra la tabla de asignaciones a todos: "1=Perro 🐶, 2=Gato 🐱, 3=Vaca 🐄..."
3. Se da 10 segundos para memorizar
4. La tabla desaparece
5. Los jugadores, por turnos, deben **contar del 1 al 10** pero diciendo el sonido del animal correspondiente
6. Si alguien se equivoca, duda demasiado, o se ríe → PIERDE
7. Se puede jugar con bomba (countdown aleatorio, si explota mientras es tu turno, pierdes)

#### Variantes
- **Modo fácil:** 5 sonidos (1-5), tabla visible más tiempo (15s)
- **Modo difícil:** 10 sonidos, tabla visible solo 8 segundos
- **Modo caos:** Cada ronda cambia el orden de los jugadores aleatoriamente

#### Asignaciones de sonidos
```dart
const animalSounds = [
  {"animal": "Perro", "emoji": "🐶", "sound": "GUAU"},
  {"animal": "Gato", "emoji": "🐱", "sound": "MIAU"},
  {"animal": "Vaca", "emoji": "🐄", "sound": "MUUU"},
  {"animal": "Gallo", "emoji": "🐓", "sound": "KIKIRIKI"},
  {"animal": "Oveja", "emoji": "🐑", "sound": "BEEE"},
  {"animal": "Cerdo", "emoji": "🐷", "sound": "OINK"},
  {"animal": "Pato", "emoji": "🦆", "sound": "CUAC"},
  {"animal": "León", "emoji": "🦁", "sound": "ROAR"},
  {"animal": "Burro", "emoji": "🫏", "sound": "IHAA"},
  {"animal": "Mono", "emoji": "🐵", "sound": "UH UH AH AH"},
  {"animal": "Serpiente", "emoji": "🐍", "sound": "SSSS"},
  {"animal": "Búho", "emoji": "🦉", "sound": "UHUU"},
  {"animal": "Rana", "emoji": "🐸", "sound": "CROAC"},
  {"animal": "Abeja", "emoji": "🐝", "sound": "BZZZ"},
  {"animal": "Elefante", "emoji": "🐘", "sound": "PRRR"},
];
```

#### Pantalla — Fase de memorización
```
┌─────────────────────────┐
│  Sound Chain  ⏱️ 10s    │
│  ¡MEMORIZA!             │
│                         │
│  1 → 🐶 GUAU           │
│  2 → 🐱 MIAU           │
│  3 → 🐄 MUUU           │
│  4 → 🐓 KIKIRIKI       │
│  5 → 🐑 BEEE           │
│  6 → 🐷 OINK           │
│  7 → 🦆 CUAC           │
│  8 → 🦁 ROAR           │
│  9 → 🫏 IHAA           │
│  10 → 🐵 UH UH AH AH  │
│                         │
└─────────────────────────┘
```

#### Pantalla — Fase de juego
```
┌─────────────────────────┐
│  Sound Chain             │
│                         │
│  Turno de: 😎 Jesús     │
│                         │
│      Número: 4          │  ← Grande, centro
│      ❓                 │  ← Interrogación (NO muestra respuesta)
│                         │
│        💣               │  ← Bomba latiendo
│                         │
│  ┌──────────┐┌──────────┐│
│  │ ✓ CORREC ││ ✗ FALLÓ  ││ ← Los demás validan
│  └──────────┘└──────────┘│
└─────────────────────────┘
```

---

### 6.5 🚫 TABÚ EXPRESS

**Jugadores:** 4-10 (2 equipos o individual)

#### Mecánica
1. Aparece una **palabra a describir** y **3-4 palabras prohibidas** debajo
2. El jugador describe la palabra SIN usar las palabras prohibidas
3. Los demás adivinan
4. Timer de **60 segundos** — cuantas más palabras acierte el equipo, mejor
5. Botones: "ACIERTO ✓" (pasa a siguiente palabra) / "PASO ⏭️" (salta sin punto) / "TABÚ ✗" (dijo palabra prohibida, punto en contra)

#### Pantalla
```
┌─────────────────────────┐
│  Tabú Express  ⏱️ 45s   │
│  😎 Jesús describe      │
│  Puntos: 4              │
│                         │
│  ┌─────────────────┐    │
│  │                 │    │
│  │   HOSPITAL      │    │  ← Palabra a describir (verde, grande)
│  │                 │    │
│  │  ✗ Médico       │    │  ← Palabras prohibidas (rojo)
│  │  ✗ Doctor       │    │
│  │  ✗ Enfermo      │    │
│  │  ✗ Cama         │    │
│  │                 │    │
│  └─────────────────┘    │
│                         │
│ ┌──────┐┌──────┐┌──────┐│
│ │  ✓   ││  ⏭️  ││  ✗   ││
│ │Acier ││ Paso ││Tabú! ││
│ └──────┘└──────┘└──────┘│
└─────────────────────────┘
```

#### Base de datos (mínimo 200 palabras)
```dart
const tabooData = [
  {"word": "Hospital", "taboo": ["Médico", "Doctor", "Enfermo", "Cama"]},
  {"word": "Playa", "taboo": ["Arena", "Mar", "Sol", "Verano"]},
  {"word": "Cumpleaños", "taboo": ["Fiesta", "Pastel", "Velas", "Regalo"]},
  {"word": "Colegio", "taboo": ["Estudiar", "Profesor", "Clase", "Alumno"]},
  {"word": "Navidad", "taboo": ["Papá Noel", "Regalo", "Árbol", "Diciembre"]},
  {"word": "Fútbol", "taboo": ["Pelota", "Gol", "Portería", "Equipo"]},
  {"word": "Boda", "taboo": ["Casarse", "Novia", "Iglesia", "Anillo"]},
  {"word": "Pizza", "taboo": ["Queso", "Tomate", "Italia", "Masa"]},
  {"word": "Dentista", "taboo": ["Diente", "Muela", "Dolor", "Boca"]},
  {"word": "Avión", "taboo": ["Volar", "Piloto", "Cielo", "Aeropuerto"]},
  {"word": "Dinosaurio", "taboo": ["Extinto", "Jurásico", "Grande", "Fósil"]},
  {"word": "Astronauta", "taboo": ["Espacio", "Luna", "Cohete", "NASA"]},
  {"word": "Vampiro", "taboo": ["Sangre", "Colmillos", "Noche", "Drácula"]},
  {"word": "Carnaval", "taboo": ["Disfraz", "Máscara", "Fiesta", "Febrero"]},
  {"word": "Selfie", "taboo": ["Foto", "Cámara", "Teléfono", "Cara"]},
  {"word": "WiFi", "taboo": ["Internet", "Conexión", "Contraseña", "Red"]},
  {"word": "Resaca", "taboo": ["Beber", "Alcohol", "Dolor", "Cabeza"]},
  {"word": "Karaoke", "taboo": ["Cantar", "Micrófono", "Música", "Bar"]},
  {"word": "Tatuaje", "taboo": ["Piel", "Aguja", "Dibujo", "Tinta"]},
  {"word": "Instagram", "taboo": ["Foto", "Red social", "Seguir", "Stories"]},
  // ... GENERAR HASTA 200+ PALABRAS CON SUS TABÚES
];
```

---

### 6.6 🔥 VERDAD O RETO

**Jugadores:** 2-10

#### Mecánica
1. Aparece el nombre del jugador actual
2. Elige: VERDAD o RETO
3. Se muestra la pregunta/reto
4. Opción: "CUMPLIDO ✓" o "SE RAJÓ 🐔" (cobarde)
5. Pasa al siguiente jugador

#### Categorías de intensidad
- 🟢 **Suave** — Apto para todos (gratis)
- 🟡 **Picante** — Más atrevido (gratis)
- 🔴 **Extremo** — Muy atrevido (desbloqueable con rewarded ad)

#### Base de datos
```dart
const truthOrDareData = {
  "verdad": {
    "suave": [
      "¿Cuál es tu canción más vergonzosa del historial?",
      "¿Cuál fue tu apodo más ridículo?",
      "¿Qué es lo más tonto que has buscado en Google?",
      "¿Cuál es la mentira más grande que has dicho a tus padres?",
      "¿Cuál es tu talento oculto más raro?",
      "¿Quién en esta sala tiene el mejor sentido del humor?",
      "¿Cuál fue tu fase más cringe de adolescente?",
      "¿Qué serie has visto en secreto sin que nadie lo sepa?",
      "¿Cuál es tu mayor red flag?",
      "¿Qué harías si fueras invisible por un día?",
      "¿Cuál es tu mayor manía?",
      "¿A quién de aquí le robarías el armario?",
      "¿Cuál es tu comfort food cuando estás triste?",
      "¿Qué es lo más random de tu lista de deseos?",
      "¿Cuál es la excusa más elaborada que has inventado?",
      "¿Cuántas alarmas pones por la mañana?",
      "¿Qué famoso/a te haría perder la cabeza?",
      "¿Cuál es tu peor hábito?",
      "¿Qué cosa de niño aún haces?",
      "¿Cuál fue tu crush más vergonzoso?",
      // ... 30+ más
    ],
    "picante": [
      "¿Cuál es el DM más vergonzoso que has enviado?",
      "¿Has stalkeado a un ex? ¿Hasta qué punto?",
      "¿Cuál es tu mayor fantasía que nunca has dicho?",
      "¿Cuántas veces al día miras el móvil de tu pareja?",
      "¿Qué es lo más loco que has hecho por amor?",
      "¿Quién de aquí besarías si tuvieras que elegir?",
      "¿Cuál fue tu peor cita?",
      "¿Has enviado un mensaje a la persona equivocada?",
      "¿Cuál es tu peor experiencia en una primera cita?",
      "¿Alguna vez has mentido sobre tu edad?",
      // ... 30+ más
    ],
    "extremo": [
      "Muestra el último mensaje de WhatsApp que enviaste",
      "Enseña tu galería de fotos por 10 segundos",
      "Lee en voz alta el último audio que enviaste",
      "Muestra tu historial de búsqueda de hoy",
      "Confiesa algo que nadie aquí sabe de ti",
      "Di el nombre de la persona que más te gusta aquí",
      "Lee el último mensaje de tu ex",
      "Muestra tu pantalla de tiempo de uso del móvil",
      "Confiesa tu mayor arrepentimiento",
      "Di algo que nunca le has dicho a tu mejor amigo/a",
      // ... 30+ más
    ]
  },
  "reto": {
    "suave": [
      "Haz tu mejor imitación de un famoso — los demás adivinan",
      "Canta el estribillo de tu canción favorita",
      "Haz 10 sentadillas ahora mismo",
      "Habla con acento argentino durante 2 rondas",
      "Haz tu mejor cara de sorpresa y que alguien te haga foto",
      "Cuenta un chiste malo — si nadie se ríe, lo lograste",
      "Baila durante 15 segundos sin música",
      "Imita a la persona de tu derecha durante 30 segundos",
      "Haz tu mejor rugido de león",
      "Di un trabalenguas sin equivocarte",
      "Mantén contacto visual con alguien durante 30 segundos",
      "Haz tu mejor impresión de un bebé llorando",
      "Haz el moonwalk (o inténtalo)",
      "Canta ópera durante 10 segundos",
      "Actúa como si fueras un robot durante 1 minuto",
      // ... 30+ más
    ],
    "picante": [
      "Publica una story en Instagram que elija el grupo",
      "Llama a la última persona de tus contactos y dile algo bonito",
      "Deja que alguien del grupo envíe un mensaje desde tu WhatsApp",
      "Haz un TikTok bailando y publícalo ahora",
      "Dale tu teléfono al grupo durante 1 minuto",
      "Envía un audio de 20 segundos cantando a un contacto random",
      "Déjate poner un apodo en tu perfil de WhatsApp",
      "Manda un sticker vergonzoso a tu último chat",
      "Haz una videollamada a alguien y actúa como si estuvieras llorando",
      "Ponte de fondo de pantalla la foto que elija el grupo",
      // ... 30+ más
    ],
    "extremo": [
      "Come una cucharada de la salsa más picante que haya",
      "Deja que el grupo publique algo en tu Instagram",
      "Haz 50 abdominales ahora mismo",
      "Sal al balcón y grita 'TE QUIERO' bien fuerte",
      "Deja que alguien te maquille con lo que haya",
      "Llama a tu madre y dile que te vas a casar",
      "Manda un 'te echo de menos' a tu ex",
      "Deja que el grupo elija tu foto de perfil por 24 horas",
      "Haz un directo de Instagram de 30 segundos haciendo algo ridículo",
      "Intercambia teléfonos con alguien durante 5 minutos",
      // ... 30+ más
    ]
  }
};
```

#### Pantalla
```
┌─────────────────────────┐
│  Verdad o Reto          │
│                         │
│     😎 JESÚS            │
│                         │
│  ┌──────────┐┌──────────┐│
│  │ 🤔       ││ 💪       ││
│  │ VERDAD   ││ RETO     ││
│  └──────────┘└──────────┘│
│                         │
│  Intensidad:            │
│  🟢 Suave               │  ← seleccionable
│  🟡 Picante             │
│  🔴 Extremo 🔒          │  ← "Ver anuncio para desbloquear"
│                         │
└─────────────────────────┘

→ Después de elegir:
┌─────────────────────────┐
│  VERDAD                 │
│                         │
│  😎 Jesús               │
│                         │
│  ┌─────────────────┐    │
│  │ ¿Cuál es tu     │    │
│  │ canción más     │    │
│  │ vergonzosa del  │    │
│  │ historial?      │    │
│  └─────────────────┘    │
│                         │
│  ┌──────────┐┌──────────┐│
│  │ ✓ CUMPLIÓ││ 🐔 SE    ││
│  │          ││ RAJÓ     ││
│  └──────────┘└──────────┘│
└─────────────────────────┘
```

---

## 7. SISTEMA DE PENALIZACIONES / CASTIGOS

Cuando un jugador pierde, además del resultado normal, se puede activar un **castigo aleatorio**. Configurable en ajustes (on/off).

```dart
const penalties = [
  "Bebe un trago 🍺",
  "Haz 10 flexiones 💪",
  "Imita al jugador de tu derecha 🎭",
  "Cuenta un chiste AHORA 😂",
  "Selfie con cara ridícula → historia de Instagram 📸",
  "Habla como robot durante la siguiente ronda 🤖",
  "Canta una canción que elija el grupo 🎤",
  "No puedes usar las manos en la siguiente ronda ✋",
  "Di un piropo al jugador de tu izquierda 💕",
  "Haz un sonido de animal durante 10 segundos 🐮",
  "Baila 15 segundos 💃",
  "Llama a alguien y cántale 'Cumpleaños Feliz' 📞",
  "Intercambia una prenda con otro jugador 👕",
  "No puedes hablar en la próxima ronda (solo gestos) 🤫",
  "Di todo al revés en la siguiente ronda 🔄",
];
```

---

## 8. MONETIZACIÓN — UNITY ADS

### Configuración
```dart
// ads_config.dart
class AdsConfig {
  // REEMPLAZAR CON TUS IDs REALES DE UNITY ADS
  static const String gameId = 'YOUR_GAME_ID';  // Android game ID
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String rewardedPlacementId = 'Rewarded_Android';
  static const String bannerPlacementId = 'Banner_Android';
  
  // Configuración de frecuencia
  static const int roundsBetweenAds = 3;        // Ad cada 3 rondas
  static const int initialFreeRounds = 5;       // Primeras 5 rondas sin ads
}
```

### Servicio de ads
```dart
// ads_service.dart
// Implementar:
// 1. init() — inicializar SDK en splash screen
// 2. loadInterstitial() — precargar interstitial
// 3. showInterstitial() — mostrar si han pasado N rondas
// 4. loadRewarded() — precargar rewarded
// 5. showRewarded(onComplete) — mostrar y ejecutar callback al completar
// 6. _roundCounter — contador de rondas para saber cuándo mostrar
```

### Lógica de cuándo mostrar ads
```
Ronda 1-5:  SIN ADS (buena primera impresión)
Ronda 6:    INTERSTITIAL
Ronda 7-8:  SIN ADS
Ronda 9:    INTERSTITIAL
Ronda 10-11: SIN ADS
Ronda 12:   INTERSTITIAL
... (cada 3 rondas a partir de ronda 6)

Rewarded: SOLO cuando el usuario elige desbloquear contenido premium
  → Al completar video → desbloquear categoría "Extremo" de Verdad o Reto
  → Guardar desbloqueo en SharedPreferences (dura 24 horas)
```

---

## 9. SISTEMA DE AUDIO

### Sonidos necesarios (archivos .mp3 en assets/sounds/)
```
sounds/
├── bomb_tick.mp3          # Tick de bomba (corto, ~0.1s)
├── bomb_tick_fast.mp3     # Tick rápido
├── bomb_explode.mp3       # Explosión (satisfying, ~1s)
├── correct.mp3            # Acierto (ding positivo)
├── wrong.mp3              # Error (buzzer)
├── timer_beep.mp3         # Beep de countdown (3-2-1)
├── whoosh.mp3             # Transición entre pantallas
├── reveal.mp3             # Revelar resultado (dramatic)
├── tap.mp3                # Sonido de botón
├── vote.mp3               # Sonido de votar
├── victory.mp3            # Victoria (fanfare corto)
└── chicken.mp3            # Sonido de gallina (para "se rajó")
```

**NOTA PARA CLAUDE CODE:** Genera estos sonidos usando `audioplayers` con tonos generados programáticamente, O usa sonidos libres de derechos. NO usar sonidos con copyright. Alternativa: usar el paquete `flutter_beep` para generar tonos simples.

---

## 10. SETTINGS SCREEN

```
┌─────────────────────────┐
│  ← Ajustes              │
│                         │
│  Sonidos          [ON]  │
│  Vibración        [ON]  │
│  Castigos         [ON]  │
│                         │
│  ─────────────────────  │
│                         │
│  Timer Word Bomb:       │
│  [Corto|Normal|Largo]   │  ← Segmented control
│                         │
│  Timer 3 en 5:          │
│  [3s | 5s | 7s]         │
│                         │
│  Timer Tabú:            │
│  [30s | 60s | 90s]      │
│                         │
│  ─────────────────────  │
│                         │
│  Borrar jugadores       │
│  guardados              │
│                         │
│  ─────────────────────  │
│                         │
│  BOOM! v1.0.0           │
│  Hecho con ❤️ en España  │
└─────────────────────────┘
```

---

## 11. BUILD & DEPLOY

### Comandos Flutter
```bash
# Crear proyecto
flutter create --org com.boom boom_party_games
cd boom_party_games

# Instalar dependencias
flutter pub get

# Generar iconos (después de configurar flutter_launcher_icons)
flutter pub run flutter_launcher_icons

# Build APK
flutter build apk --release

# Build App Bundle (para Play Store)
flutter build appbundle --release
```

### AndroidManifest.xml — Permisos
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<!-- NO necesita más permisos — es offline-first -->
```

### Icono de la app
- Fondo: gradiente rojo-naranja (#E94560 → #FF6B35)
- Centro: emoji 💣 blanco grande
- Formato: 1024x1024px, bordes redondeados automáticos por Android

### Info de Google Play Store
```
Nombre: BOOM! Party Games
Descripción corta: ¡El juego de fiesta más divertido! Word Bomb, Impostor, y más.
Categoría: Casual / Party
Clasificación: PEGI 12 / T (Teen)
Precio: Gratis (con anuncios)
```

---

## 12. PRIORIDADES DE IMPLEMENTACIÓN

### Fase 1 — MVP (primer build funcional)
1. ✅ Estructura Flutter + navegación
2. ✅ Player Setup Screen
3. ✅ Game Selector Screen
4. ✅ Word Bomb (juego completo)
5. ✅ El Impostor (juego completo)
6. ✅ 3 en 5 (juego completo)
7. ✅ Unity Ads integrado
8. ✅ Sonidos básicos + vibración

### Fase 2 — Contenido completo
9. Sound Chain
10. Tabú Express
11. Verdad o Reto
12. Sistema de castigos/penalizaciones
13. Settings screen completa
14. Bases de datos completas (todas las palabras/categorías)

### Fase 3 — Polish
15. Animaciones pulidas
16. Transiciones suaves
17. Splash screen
18. Icono + screenshots para Play Store
19. Optimización de rendimiento
20. Testing en múltiples dispositivos

---

## 13. NOTAS IMPORTANTES PARA CLAUDE CODE

1. **NO uses Firebase** — la app es offline-first, todo local
2. **NO uses state management complejo** (ni Bloc, ni Riverpod) — usa StatefulWidget + setState, es suficiente para esta app
3. **Genera TODAS las bases de datos de palabras completas** — no dejes placeholders
4. **Los timers de Word Bomb deben ser ALEATORIOS** (8-20s) y NO visibles al jugador
5. **Cada juego es independiente** — se puede jugar cualquiera sin pasar por otro
6. **Guarda los nombres de jugadores en SharedPreferences** — que persistan
7. **Los ads NO deben bloquear el juego** — si falla la carga, continúa sin ad
8. **Portrait mode obligatorio** — bloquear orientación
9. **Target: Android** — no necesitamos iOS por ahora
10. **Idioma de la app: Español** — todos los textos en español
11. **El nombre del paquete es: com.boom.partygames**
12. **Genera mínimo 100 restricciones para Word Bomb, 30 palabras por categoría en Impostor, 150 categorías en 3 en 5, 200 palabras en Tabú, 30+ preguntas/retos por nivel de intensidad**
