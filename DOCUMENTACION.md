# CheckPoint - Documentación del Proyecto

## Índice

1. [Introducción](#1-introducción)
   - 1.1. [Descripción del proyecto](#11-descripción-del-proyecto)
   - 1.2. [Objetivos](#12-objetivos)
   - 1.3. [Justificación](#13-justificación)
   - 1.4. [Alcance](#14-alcance)

2. [Análisis de Requisitos](#2-análisis-de-requisitos)
   - 2.1. [Requisitos funcionales](#21-requisitos-funcionales)
   - 2.2. [Requisitos no funcionales](#22-requisitos-no-funcionales)
   - 2.3. [Casos de uso](#23-casos-de-uso)
   - 2.4. [Diagramas UML](#24-diagramas-uml)

3. [Tecnologías Utilizadas](#3-tecnologías-utilizadas)
4. [Arquitectura del Sistema](#4-arquitectura-del-sistema)
5. [Diseño de la Aplicación](#5-diseño-de-la-aplicación)
6. [Implementación](#6-implementación)
7. [Pruebas](#7-pruebas)
8. [Manual de Usuario](#8-manual-de-usuario)
9. [Conclusiones y Mejoras Futuras](#9-conclusiones-y-mejoras-futuras)
10. [Bibliografía](#10-bibliografía)

---

## 1. Introducción

### 1.1. Descripción del proyecto

**CheckPoint** es una aplicación móvil desarrollada con **Flutter** que permite a los usuarios descubrir videojuegos y soundtracks de manera intuitiva y moderna. La aplicación integra múltiples servicios externos para ofrecer una experiencia completa:

- **Búsqueda y exploración** de videojuegos a través de la API de IGDB (Internet Game Database)
- **Visualización de biblioteca personal** con juegos guardados sincronizados en Firebase Firestore
- **Descubrimiento de soundtracks populares** mediante integración con Spotify API
- **Sistema de autenticación** seguro con Firebase Authentication
- **Modo invitado** que permite acceso limitado sin necesidad de registro

La aplicación está diseñada siguiendo los principios de **Clean Architecture**, garantizando un código mantenible, escalable y testeable. Utiliza **Material Design 3** para ofrecer una interfaz moderna y accesible, con un tema oscuro personalizado que mejora la experiencia de usuario.

### 1.2. Objetivos

#### Objetivo General

Desarrollar una aplicación móvil que facilite a los usuarios el descubrimiento de videojuegos y soundtracks, integrando múltiples fuentes de información en una experiencia unificada y atractiva.

#### Objetivos Específicos

1. **Autenticación y Seguridad**
   - Implementar un sistema de registro e inicio de sesión seguro mediante Firebase Authentication
   - Gestionar el estado de autenticación de forma persistente
   - Permitir acceso limitado en modo invitado
   - Proteger los datos del usuario mediante validación y sanitización

2. **Descubrimiento de Videojuegos**
   - Integrar la API de IGDB para búsqueda de videojuegos
   - Mostrar juegos populares en el Feed
   - Implementar sistema de búsqueda con mínimo 3 caracteres
   - Mostrar resultados con portadas y títulos

3. **Biblioteca Personal**
   - Visualizar juegos guardados en biblioteca
   - Sincronizar la biblioteca con Firebase Firestore
   - Mostrar contador de juegos totales

4. **Integración Musical**
   - Conectar con Spotify API para descubrir soundtracks populares
   - Mostrar información de álbumes (portada, artista, fecha)
   - Presentar soundtracks destacados en el Feed

5. **Experiencia de Usuario**
   - Diseñar una interfaz moderna siguiendo Material Design 3
   - Implementar navegación adaptativa por pestañas (autenticados vs invitados)
   - Aplicar tema oscuro personalizado para reducir fatiga visual
   - Garantizar rendimiento fluido con 60 FPS constantes

6. **Arquitectura y Calidad de Código**
   - Implementar Clean Architecture con separación en capas (Domain, Data, Presentation)
   - Aplicar patrón Repository para abstracción de fuentes de datos
   - Seguir las pautas de **Effective Dart** al 100%
   - Mantener código explícito sin operadores compactos
   - Garantizar mantenibilidad y escalabilidad del código

### 1.3. Justificación

#### Motivación Personal

Como desarrollador y gamer, he identificado la necesidad de una herramienta que unifique la gestión de mi biblioteca de videojuegos con el descubrimiento de nuevos títulos y sus bandas sonoras. Las aplicaciones existentes suelen enfocarse solo en catalogación o solo en descubrimiento, pero raramente integran ambas funcionalidades de forma efectiva.

#### Necesidad del Mercado

El mercado de videojuegos ha crecido exponencialmente en los últimos años, y con él la cantidad de títulos disponibles. Los usuarios necesitan herramientas que les ayuden a:

- **Organizar** su biblioteca de juegos en un solo lugar
- **Descubrir** nuevos títulos basados en géneros y plataformas
- **Acceder** a información confiable y actualizada
- **Explorar** las bandas sonoras que acompañan sus juegos favoritos

#### Valor Diferencial

CheckPoint se diferencia de la competencia al:

1. **Integrar múltiples servicios** (IGDB + Spotify + Firebase) en una sola aplicación
2. **Ofrecer sincronización en la nube** para acceso desde cualquier dispositivo
3. **Proporcionar filtrado inteligente** de soundtracks oficiales vs compilaciones
4. **Seguir estándares profesionales** de arquitectura y calidad de código

#### Aplicación de Conocimientos DAM

Este proyecto me permite aplicar y demostrar competencias clave del ciclo de **Desarrollo de Aplicaciones Multiplataforma**:

- **Programación**: Dart, Flutter, patrones de diseño
- **Bases de datos**: Firebase Firestore (NoSQL), modelado de datos
- **Desarrollo de interfaces**: Material Design, UX/UI
- **Integración de servicios**: APIs RESTful, OAuth 2.0
- **Arquitectura de software**: Clean Architecture, SOLID
- **Control de versiones**: Git, GitHub
- **Gestión de proyectos**: Metodologías ágiles, documentación

### 1.4. Alcance

#### Funcionalidades Incluidas

**Versión 1.0** (Alcance actual):

- ✅ Sistema completo de autenticación (registro, login, logout)
- ✅ Búsqueda de videojuegos por nombre
- ✅ Visualización de juegos populares en el Feed
- ✅ Visualización de biblioteca personal (juegos guardados)
- ✅ Descubrimiento de soundtracks populares
- ✅ Navegación adaptativa por pestañas (autenticados: 4 pestañas / invitados: 2 pestañas)
- ✅ Sincronización en la nube con Firebase Firestore
- ✅ Caché de géneros para optimización
- ✅ Tema oscuro Material Design 3
- ✅ Modo invitado con acceso limitado

#### Limitaciones Conocidas

- **Plataformas**: Solo Android
- **Idioma**: Interfaz únicamente en español
- **Conectividad**: Requiere conexión a internet para funcionar
- **APIs externas**: Dependiente de disponibilidad de IGDB y Spotify
- **Autenticación**: Solo email/password (sin Google, Facebook, Apple Sign-In)
- **Funcionalidad limitada**: No hay pantalla de detalles de juego ni gestión completa de biblioteca

#### Funcionalidades Futuras (Fuera de Alcance v1.0)

- 🔜 Pantalla de detalles de juego con información completa
- 🔜 Añadir/eliminar juegos de biblioteca desde la app
- 🔜 Búsqueda de soundtracks por juego específico
- 🔜 Edición de perfil de usuario (nombre, avatar)
- 🔜 Estadísticas de biblioteca (total de juegos, géneros favoritos)
- 🔜 Sistema de reseñas y calificaciones de usuarios
- 🔜 Recomendaciones personalizadas basadas en IA
- 🔜 Chat/comunidad entre usuarios
- 🔜 Integración con tiendas (Steam, Epic, PlayStation Store)
- 🔜 Notificaciones de lanzamientos de juegos favoritos
- 🔜 Soporte multiidioma (inglés, francés, alemán)
- 🔜 Modo offline con sincronización diferida
- 🔜 Exportar/importar biblioteca en formatos CSV, JSON
- 🔜 Filtros avanzados (por género, plataforma, año)

---

## 2. Análisis de Requisitos

### 2.1. Requisitos funcionales

#### RF-001: Autenticación de Usuarios

**Descripción**: El sistema debe permitir a los usuarios registrarse, iniciar sesión y cerrar sesión de forma segura.

**Prioridad**: Alta

**Criterios de aceptación**:
- El usuario puede registrarse con email y contraseña
- El sistema valida el formato de email y fortaleza de contraseña
- El usuario puede iniciar sesión con credenciales registradas
- El usuario puede cerrar sesión en cualquier momento
- La sesión persiste entre aperturas de la aplicación
- Se muestran mensajes de error claros en caso de fallo

**Estado**: ✅ Implementado

---

#### RF-002: Búsqueda de Videojuegos

**Descripción**: El sistema debe permitir buscar videojuegos por nombre utilizando la API de IGDB.

**Prioridad**: Alta

**Criterios de aceptación**:
- El usuario puede introducir un término de búsqueda
- El sistema muestra resultados en tiempo real (mínimo 3 caracteres)
- Los resultados incluyen: portada, título, fecha de lanzamiento, plataformas
- Se muestran máximo 20 resultados por búsqueda
- Se muestra mensaje informativo si no hay resultados
- La búsqueda funciona con términos en inglés y español

**Estado**: ✅ Implementado

---

#### RF-003: Gestión de Biblioteca Personal

**Descripción**: El sistema debe permitir al usuario visualizar juegos guardados en su biblioteca.

**Prioridad**: Alta

**Criterios de aceptación**:
- Se muestra lista de juegos guardados con portadas
- Se muestra contador de juegos totales
- La biblioteca se sincroniza automáticamente con Firebase
- Los datos persisten entre sesiones
- Se muestra mensaje si la biblioteca está vacía

**Estado**: ✅ Implementado

---

#### RF-004: Descubrimiento de Soundtracks

**Descripción**: El sistema debe mostrar soundtracks populares de videojuegos mediante Spotify.

**Prioridad**: Media

**Criterios de aceptación**:
- Se integra Spotify API con autenticación OAuth
- Se muestran soundtracks populares automáticamente en el Feed
- Se muestran portadas de álbumes en alta calidad
- Se muestra nombre del álbum y artista
- Se muestra fecha de lanzamiento del soundtrack

**Estado**: ✅ Implementado

---

#### RF-005: Navegación por Pestañas

**Descripción**: El sistema debe proporcionar navegación intuitiva mediante pestañas principales.

**Prioridad**: Alta

**Criterios de aceptación**:
- Se muestran 4 pestañas para usuarios autenticados: Inicio, Búsqueda, Biblioteca, Perfil
- Se muestran 2 pestañas para usuarios invitados: Inicio, Búsqueda
- Cada pestaña tiene icono representativo
- La pestaña activa se resalta visualmente
- La transición entre pestañas es fluida
- Se mantiene el estado de cada pestaña al cambiar

**Estado**: ✅ Implementado

---

#### RF-006: Gestión de Perfil de Usuario

**Descripción**: El sistema debe mostrar información básica del perfil del usuario autenticado.

**Prioridad**: Media

**Criterios de aceptación**:
- Se muestra email del usuario
- Se incluye botón de cerrar sesión funcional
- El usuario puede cerrar sesión correctamente

**Estado**: ✅ Implementado

---

#### RF-007: Modo Invitado

**Descripción**: El sistema debe permitir el acceso limitado sin autenticación.

**Prioridad**: Media

**Criterios de aceptación**:
- Los usuarios no autenticados pueden ver el Feed de juegos populares
- Los usuarios no autenticados pueden buscar juegos
- Los usuarios no autenticados NO pueden acceder a Biblioteca ni Perfil
- Se muestra navegación adaptada (solo Inicio y Búsqueda)

**Estado**: ✅ Implementado

---

### 2.2. Requisitos no funcionales

#### RNF-001: Rendimiento

**Descripción**: La aplicación debe mantener un rendimiento fluido y responsivo.

**Criterios de aceptación**:
- La aplicación debe mantener 60 FPS en dispositivos de gama media
- El tiempo de carga inicial no debe superar 3 segundos
- Las búsquedas deben mostrar resultados en menos de 2 segundos
- Las imágenes deben cargarse progresivamente (placeholder → imagen)
- La navegación entre pantallas debe ser instantánea (<300ms)

**Prioridad**: Alta

**Estado**: ✅ Cumplido

---

#### RNF-002: Seguridad

**Descripción**: La aplicación debe proteger los datos del usuario y comunicaciones.

**Criterios de aceptación**:
- Todas las comunicaciones con Firebase usan HTTPS
- Las credenciales no se almacenan en texto plano
- Las claves API están protegidas (no expuestas en código)
- Se valida toda entrada de usuario antes de procesarla
- Se implementa autenticación basada en tokens (Firebase Auth)
- Las reglas de Firestore protegen datos de usuarios no autorizados

**Prioridad**: Alta

**Estado**: ✅ Cumplido

---

#### RNF-003: Usabilidad

**Descripción**: La aplicación debe ser intuitiva y fácil de usar.

**Criterios de aceptación**:
- La interfaz sigue las guías de Material Design 3
- Los botones y elementos interactivos tienen área táctil mínima de 48dp
- Se muestran mensajes de feedback para todas las acciones
- Se usan animaciones sutiles para guiar la atención del usuario
- Los errores se muestran de forma clara y accionable
- La navegación es consistente en toda la aplicación

**Prioridad**: Alta

**Estado**: ✅ Cumplido

---

#### RNF-004: Compatibilidad

**Descripción**: La aplicación debe funcionar en un amplio rango de dispositivos.

**Criterios de aceptación**:
- Soporte para Android 6.0 (API 23) en adelante
- Diseño responsive que se adapta a diferentes tamaños de pantalla
- Funciona en smartphones y tablets
- Soporta orientación vertical (portrait)

**Prioridad**: Alta

**Estado**: ✅ Cumplido

---

#### RNF-005: Mantenibilidad

**Descripción**: El código debe ser fácil de mantener y extender.

**Criterios de aceptación**:
- Arquitectura Clean Architecture claramente definida
- Separación de responsabilidades en capas (Domain, Data, Presentation)
- Código documentado con comentarios significativos
- Cumplimiento 100% de Effective Dart
- Código explícito y sin operadores compactos
- Patrones de diseño aplicados consistentemente
- Inyección de dependencias bien implementada

**Prioridad**: Alta

**Estado**: ✅ Cumplido

---

#### RNF-006: Escalabilidad

**Descripción**: La arquitectura debe permitir crecimiento futuro sin refactorización mayor.

**Criterios de aceptación**:
- Nuevas features pueden añadirse sin modificar features existentes
- Nuevas fuentes de datos pueden integrarse sin cambiar lógica de negocio
- Nuevos providers de autenticación pueden añadirse fácilmente
- El sistema de caché es extensible
- Las interfaces permiten cambio de implementaciones

**Prioridad**: Media

**Estado**: ✅ Cumplido

---

#### RNF-007: Disponibilidad

**Descripción**: La aplicación debe estar disponible cuando el usuario la necesite.

**Criterios de aceptación**:
- La aplicación arranca correctamente el 99.9% de las veces
- Firebase tiene SLA del 99.95% (garantizado por Google)
- Se implementan reintentos automáticos en caso de fallos de red
- Se muestran mensajes informativos cuando servicios externos no están disponibles
- No hay single points of failure críticos

**Prioridad**: Media

**Estado**: ✅ Cumplido

---

### 2.3. Casos de uso

#### CU-001: Registro de Nuevo Usuario

**Actor principal**: Usuario no registrado

**Precondiciones**: 
- El usuario no tiene cuenta en la aplicación
- Hay conexión a internet

**Flujo principal**:
1. El usuario abre la aplicación
2. El sistema muestra la pantalla de bienvenida (WelcomePage)
3. El usuario selecciona "Registrarse"
4. El sistema muestra el formulario de registro (RegisterPage)
5. El usuario ingresa email y contraseña
6. El usuario confirma la contraseña
7. El usuario pulsa "Crear cuenta"
8. El sistema valida los datos ingresados
9. El sistema crea la cuenta en Firebase Authentication
10. El sistema redirige al usuario a la pantalla principal (HomePage)

**Flujos alternativos**:
- **8a. Email inválido**: El sistema muestra error "Email no válido"
- **8b. Contraseña débil**: El sistema muestra error "La contraseña debe tener al menos 6 caracteres"
- **8c. Contraseñas no coinciden**: El sistema muestra error "Las contraseñas no coinciden"
- **9a. Email ya registrado**: El sistema muestra error "Este email ya está registrado"
- **9b. Error de red**: El sistema muestra error "Error de conexión. Inténtalo de nuevo"

**Postcondiciones**:
- Se crea una cuenta de usuario en Firebase
- El usuario queda autenticado automáticamente
- Se redirige a la pantalla principal

---

#### CU-002: Inicio de Sesión

**Actor principal**: Usuario registrado

**Precondiciones**:
- El usuario tiene cuenta creada
- El usuario no está autenticado
- Hay conexión a internet

**Flujo principal**:
1. El usuario abre la aplicación
2. El sistema muestra la pantalla de bienvenida
3. El usuario selecciona "Iniciar sesión"
4. El sistema muestra el formulario de login (LoginPage)
5. El usuario ingresa email y contraseña
6. El usuario pulsa "Entrar"
7. El sistema valida las credenciales en Firebase
8. El sistema redirige al usuario a la pantalla principal

**Flujos alternativos**:
- **7a. Credenciales incorrectas**: El sistema muestra error "Email o contraseña incorrectos"
- **7b. Usuario no encontrado**: El sistema muestra error "No existe cuenta con este email"
- **7c. Error de red**: El sistema muestra error "Error de conexión. Inténtalo de nuevo"

**Postcondiciones**:
- El usuario queda autenticado
- Se inicia sesión persistente
- Se redirige a la pantalla principal

---

#### CU-003: Búsqueda de Videojuego

**Actor principal**: Usuario autenticado

**Precondiciones**:
- El usuario está autenticado
- Hay conexión a internet
- El usuario está en la pestaña "Búsqueda"

**Flujo principal**:
1. El usuario ingresa término de búsqueda en el campo de texto
2. El sistema espera a que se ingresen al menos 3 caracteres
3. El sistema realiza petición a IGDB API
4. El sistema muestra loading spinner
5. El sistema recibe respuesta de IGDB
6. El sistema muestra grid de resultados con portadas y títulos
7. El usuario visualiza los juegos encontrados

**Flujos alternativos**:
- **3a. Sin conexión**: El sistema muestra error "Sin conexión a internet"
- **5a. Sin resultados**: El sistema muestra mensaje "No se encontraron juegos"
- **5b. Error de API**: El sistema muestra error "Error al buscar juegos. Inténtalo de nuevo"

**Postcondiciones**:
- Se muestran resultados de búsqueda con portadas y nombres

---

#### CU-004: Ver Biblioteca Personal

**Actor principal**: Usuario autenticado

**Precondiciones**:
- El usuario está autenticado
- Hay conexión a internet

**Flujo principal**:
1. El usuario selecciona pestaña "Biblioteca"
2. El sistema carga juegos guardados desde Firebase Firestore
3. El sistema muestra loading indicator
4. El sistema recibe lista de juegos
5. El sistema muestra grid de juegos con portadas y títulos
6. El usuario visualiza su colección

**Flujos alternativos**:
- **4a. Biblioteca vacía**: El sistema muestra mensaje "Tu biblioteca está vacía"
- **4b. Error de red**: El sistema muestra error "No se pudo cargar la biblioteca"

**Postcondiciones**:
- Se muestra lista de juegos guardados con portadas

---

#### CU-005: Ver Feed de Juegos Populares

**Actor principal**: Usuario (autenticado o invitado)

**Precondiciones**:
- Hay conexión a internet

**Flujo principal**:
1. El usuario abre la aplicación o selecciona pestaña "Inicio"
2. El sistema carga automáticamente juegos populares desde IGDB
3. El sistema carga automáticamente soundtracks populares desde Spotify
4. El sistema muestra loading indicators
5. El sistema recibe respuestas de las APIs
6. El sistema muestra sección "Juegos Populares" con grid de portadas
7. El sistema muestra sección "Soundtracks Destacados" con lista de álbumes
8. El usuario visualiza el contenido popular

**Flujos alternativos**:
- **5a. Error de IGDB**: El sistema muestra mensaje de error en la sección de juegos
- **5b. Error de Spotify**: El sistema muestra mensaje de error en la sección de soundtracks
- **5c. Sin conexión**: El sistema muestra error general "Sin conexión a internet"

**Postcondiciones**:
- Se muestran juegos populares con portadas
- Se muestran soundtracks destacados con portadas y nombres

---

#### CU-006: Cerrar Sesión

**Actor principal**: Usuario autenticado

**Precondiciones**:
- El usuario está autenticado

**Flujo principal**:
1. El usuario selecciona pestaña "Perfil"
2. El usuario pulsa botón "Cerrar sesión"
3. El sistema cierra la sesión en Firebase
4. El sistema limpia datos de sesión local
5. El sistema redirige a la pantalla de bienvenida (WelcomePage)

**Flujos alternativos**:
- **3a. Error al cerrar sesión**: El sistema muestra error pero igualmente cierra sesión local

**Postcondiciones**:
- El usuario queda desautenticado
- Se elimina token de sesión
- Se redirige a pantalla de bienvenida

---

### 2.4. Diagramas UML

#### Diagrama de Casos de Uso

```
┌────────────────────────────────────────────────────────────┐
│                    CheckPoint App                          │
│                                                            │
│  ┌──────────┐                                             │
│  │ Usuario  │                                             │
│  │    No    │                                             │
│  │Registrado│                                             │
│  └─────┬────┘                                             │
│        │                                                   │
│        ├──────► (Registrarse)                             │
│        │                                                   │
│        ├──────► (Iniciar Sesión) ◄──────┐                │
│        │                                 │                │
│        └──────► (Ver Feed) ◄─────────────┤               │
│                      │                   │                │
│                      │                   │                │
│  ┌──────────┐        │                   │                │
│  │ Usuario  │        │                   │                │
│  │Registrado│────────┴───────────────────┘                │
│  └─────┬────┘                                             │
│        │                                                   │
│        ├──────► (Buscar Videojuego)                       │
│        │                                                   │
│        ├──────► (Ver Biblioteca)                          │
│        │                                                   │
│        └──────► (Cerrar Sesión)                           │
│                                                            │
│  Actores Externos:                                        │
│  ┌──────────┐   ┌──────────┐   ┌──────────┐             │
│  │ Firebase │   │   IGDB   │   │ Spotify  │             │
│  │   Auth   │   │   API    │   │   API    │             │
│  └──────────┘   └──────────┘   └──────────┘             │
└────────────────────────────────────────────────────────────┘
```

---

#### Diagrama de Clases (Domain Layer)

```
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────┐                                  │
│  │    AuthUser      │ (Entity)                         │
│  ├──────────────────┤                                  │
│  │ - id: String     │                                  │
│  │ - email: String  │                                  │
│  │ - displayName: String? │                            │
│  │ - photoUrl: String?    │                            │
│  └──────────────────┘                                  │
│                                                         │
│  ┌──────────────────────────────────────┐              │
│  │           Game                       │ (Entity)     │
│  ├──────────────────────────────────────┤              │
│  │ - id: int                            │              │
│  │ - name: String                       │              │
│  │ - summary: String?                   │              │
│  │ - coverUrl: String?                  │              │
│  │ - releaseDate: DateTime?             │              │
│  │ - rating: double?                    │              │
│  │ - genres: List<String>               │              │
│  │ - platforms: List<String>            │              │
│  │ - developers: List<String>           │              │
│  │ - publishers: List<String>           │              │
│  └──────────────────────────────────────┘              │
│                                                         │
│  ┌──────────────────────────────────────┐              │
│  │        Soundtrack                    │ (Entity)     │
│  ├──────────────────────────────────────┤              │
│  │ - id: String                         │              │
│  │ - name: String                       │              │
│  │ - artists: List<String>              │              │
│  │ - coverUrl: String?                  │              │
│  │ - releaseDate: DateTime?             │              │
│  │ - gameName: String?                  │              │
│  └──────────────────────────────────────┘              │
│                                                         │
│  ┌──────────────────────────────────────┐              │
│  │    <<abstract>>                      │              │
│  │    AuthRepository                    │ (Interface)  │
│  ├──────────────────────────────────────┤              │
│  │ + signIn(email, password): Future<AuthUser?> │     │
│  │ + signUp(email, password): Future<AuthUser?> │     │
│  │ + signOut(): Future<void>            │              │
│  │ + currentUser: AuthUser?             │              │
│  │ + authStateChanges(): Stream<AuthUser?> │          │
│  └──────────────────────────────────────┘              │
│                                                         │
│  ┌──────────────────────────────────────┐              │
│  │    <<abstract>>                      │              │
│  │    GameRepository                    │ (Interface)  │
│  ├──────────────────────────────────────┤              │
│  │ + searchGames(query): Future<List<Game>> │         │
│  │ + getGameDetails(id): Future<Game?>  │              │
│  └──────────────────────────────────────┘              │
│                                                         │
│  ┌──────────────────────────────────────┐              │
│  │    <<abstract>>                      │              │
│  │  SoundtrackRepository                │ (Interface)  │
│  ├──────────────────────────────────────┤              │
│  │ + getSoundtrackForGame(name): Future<Soundtrack?> │ │
│  └──────────────────────────────────────┘              │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

#### Diagrama de Secuencia: Búsqueda de Juegos

```
Usuario      HomePage    GameController    GameRepository    IGDB API
   │             │              │                 │              │
   │  Ingresa    │              │                 │              │
   │  "Zelda"    │              │                 │              │
   ├────────────►│              │                 │              │
   │             │  searchGames │                 │              │
   │             │   ("Zelda")  │                 │              │
   │             ├─────────────►│                 │              │
   │             │              │  searchGames    │              │
   │             │              │   ("Zelda")     │              │
   │             │              ├────────────────►│              │
   │             │              │                 │  GET /games  │
   │             │              │                 │  ?search=Zelda│
   │             │              │                 ├─────────────►│
   │             │              │                 │              │
   │             │              │                 │ JSON Response│
   │             │              │                 │◄─────────────┤
   │             │              │  List<GameModel>│              │
   │             │              │◄────────────────┤              │
   │             │              │                 │              │
   │             │              │ toEntity()      │              │
   │             │              │────┐            │              │
   │             │              │    │            │              │
   │             │              │◄───┘            │              │
   │             │  List<Game>  │                 │              │
   │             │◄─────────────┤                 │              │
   │             │              │                 │              │
   │  Muestra    │              │                 │              │
   │  grid con   │              │                 │              │
   │  portadas   │              │                 │              │
   │◄────────────┤              │                 │              │
   │             │              │                 │              │
```

---

#### Diagrama de Componentes (Clean Architecture)

```
┌────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   HomePage   │  │  LoginPage   │  │ RegisterPage │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                 │                  │                 │
│         ▼                 ▼                  ▼                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │GameController│  │AuthController│  │SoundtrackCtrl│        │
│  │(ChangeNotifier)  │(ChangeNotifier)  │(ChangeNotifier)│    │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
└─────────┼──────────────────┼──────────────────┼────────────────┘
          │                  │                  │
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼────────────────┐
│         │     DOMAIN LAYER │(Interfaces)      │                │
│         ▼                  ▼                  ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │GameRepository│  │AuthRepository│  │SoundtrackRepo│        │
│  │ (interface)  │  │ (interface)  │  │ (interface)  │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │     Game     │  │   AuthUser   │  │  Soundtrack  │        │
│  │   (Entity)   │  │   (Entity)   │  │   (Entity)   │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└─────────┬──────────────────┬──────────────────┬────────────────┘
          │                  │                  │
          │                  │                  │
┌─────────┼──────────────────┼──────────────────┼────────────────┐
│         │      DATA LAYER  │(Implementations) │                │
│         ▼                  ▼                  ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │ GameRepoImpl │  │FirebaseAuth  │  │SoundtrackRepo│        │
│  │              │  │  Repository  │  │     Impl     │        │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘        │
│         │                  │                  │                │
│         ▼                  ▼                  ▼                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │  GameModel   │  │   Firebase   │  │  SpotifyRepo │        │
│  │              │  │     Auth     │  │     Impl     │        │
│  └──────┬───────┘  └──────────────┘  └──────┬───────┘        │
│         │                                    │                │
│         ▼                                    ▼                │
│  ┌──────────────┐                    ┌──────────────┐        │
│  │  IgdbClient  │                    │SpotifySoundtrack│      │
│  │  (API)       │                    │    Model     │        │
│  └──────────────┘                    └──────────────┘        │
└────────────────────────────────────────────────────────────────┘
          │                                    │
          ▼                                    ▼
┌────────────────────────────────────────────────────────────────┐
│                    EXTERNAL SERVICES                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   IGDB API   │  │   Firebase   │  │  Spotify API │        │
│  │   (Twitch)   │  │  (Google)    │  │              │        │
│  └──────────────┘  └──────────────┘  └──────────────┘        │
└────────────────────────────────────────────────────────────────┘
```

---

**NOTA**: Los apartados 3-10 (Tecnologías, Arquitectura, Diseño, Implementación, Pruebas, Manual de Usuario, Conclusiones y Bibliografía) se desarrollarán en la siguiente fase de la documentación.

---

## Anexos

### Anexo A: Estructura del Proyecto

Ver estructura completa del código en: `README.md`

### Anexo B: Enlaces de Referencia

- **IGDB API**: https://api-docs.igdb.com/
- **Spotify API**: https://developer.spotify.com/documentation/web-api
- **Firebase**: https://firebase.google.com/docs
- **Flutter**: https://flutter.dev/docs
- **Effective Dart**: https://dart.dev/effective-dart
- **Material Design 3**: https://m3.material.io/

### Anexo C: Glosario de Términos

- **Clean Architecture**: Arquitectura de software que separa responsabilidades en capas independientes
- **Domain Layer**: Capa que contiene la lógica de negocio y entidades del dominio
- **Data Layer**: Capa que gestiona fuentes de datos (APIs, bases de datos, caché)
- **Presentation Layer**: Capa que gestiona la UI y la interacción con el usuario
- **Repository Pattern**: Patrón que abstrae el acceso a datos detrás de interfaces
- **Entity**: Objeto del dominio que representa un concepto del negocio
- **Model**: Objeto que representa datos de una fuente externa (API, DB)
- **Provider**: Sistema de gestión de estado en Flutter
- **ChangeNotifier**: Clase que notifica cambios a los widgets suscritos
- **IGDB**: Internet Game Database - base de datos de videojuegos
- **Firestore**: Base de datos NoSQL en tiempo real de Firebase
- **OAuth 2.0**: Protocolo de autorización usado por Spotify
- **Material Design**: Sistema de diseño de Google para interfaces de usuario
