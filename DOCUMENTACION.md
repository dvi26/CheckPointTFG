# CheckPoint - Documentación del Proyecto

## Tabla de Contenido

1. [Estudio de Viabilidad del Sistema (EVS)](#1-estudio-de-viabilidad-del-sistema-evs)
   - 1.1. [Objetivos del EVS](#11-objetivos-del-evs)
   - 1.2. [Establecimiento del alcance del sistema](#12-establecimiento-del-alcance-del-sistema)
   - 1.3. [Estudio de la Situación Actual](#13-estudio-de-la-situación-actual)
   - 1.4. [Estudio de Alternativas de Construcción](#14-estudio-de-alternativas-de-construcción)
   - 1.5. [Estudio de Riesgos](#15-estudio-de-riesgos)

2. [Gestión de Proyectos](#2-gestión-de-proyectos)
   - 2.1. [Metodología](#21-metodología)
   - 2.2. [Planificación (Backlog y Sprints)](#22-planificación-backlog-y-sprints)

3. [Análisis de Sistemas de Información (ASI)](#3-análisis-de-sistemas-de-información-asi)
   - 3.1. [Descripción General del Entorno Tecnológico](#31-descripción-general-del-entorno-tecnológico)
   - 3.2. [Catálogo de Usuarios](#32-catálogo-de-usuarios)
   - 3.3. [Catálogo de Requisitos](#33-catálogo-de-requisitos)
   - 3.4. [Modelo de Casos de Uso](#34-modelo-de-casos-de-uso)
   - 3.5. [Interfaces de Usuario](#35-interfaces-de-usuario)

---

## 1. Estudio de Viabilidad del Sistema (EVS)

### 1.1. Objetivos del EVS

El objetivo de este estudio es analizar la viabilidad técnica, económica y operativa del proyecto **CheckPoint**, definiendo su alcance, identificando los riesgos y seleccionando la mejor alternativa tecnológica para su desarrollo. Se busca justificar la creación de una herramienta unificada para la gestión y descubrimiento de videojuegos y sus bandas sonoras.

### 1.2. Establecimiento del alcance del sistema

#### 1.2.1. Descripción General del Sistema

**CheckPoint** es una aplicación móvil desarrollada con **Flutter** que permite a los usuarios descubrir videojuegos y soundtracks de manera intuitiva y moderna. La aplicación integra múltiples servicios externos para ofrecer una experiencia completa:

- **Búsqueda y exploración** de videojuegos a través de la API de IGDB.
- **Visualización de biblioteca personal** con juegos guardados sincronizados en Firebase Firestore.
- **Descubrimiento de soundtracks populares** mediante integración con Spotify API.
- **Sistema de autenticación** seguro con Firebase Authentication.

#### 1.2.2. Objetivos del Proyecto

**Objetivo General:**
Desarrollar una aplicación móvil que facilite a los usuarios el descubrimiento de videojuegos y soundtracks, integrando múltiples fuentes de información en una experiencia unificada y atractiva.

**Objetivos Específicos:**
1.  Implementar un sistema de autenticación seguro (Registro/Login).
2.  Integrar la API de IGDB para obtener información veraz de videojuegos.
3.  Integrar la API de Spotify para vincular bandas sonoras oficiales.
4.  Permitir la gestión de una biblioteca personal sincronizada en la nube.
5.  Desarrollar una interfaz moderna basada en Material Design 3.

#### 1.2.3. Alcance Funcional

**Funcionalidades Incluidas (Versión 1.0):**
- ✅ Sistema completo de autenticación.
- ✅ Búsqueda de videojuegos por nombre.
- ✅ Feed de juegos populares y soundtracks destacados.
- ✅ Pantallas de detalles para juegos y soundtracks.
- ✅ Biblioteca personal (visualización).
- ✅ Modo invitado con acceso limitado.
- ✅ Sincronización en la nube (Firestore).

**Fuera de Alcance (Futuras versiones):**
- ❌ Sistema de reseñas y comentarios.
- ❌ Chat o funciones sociales.
- ❌ Notificaciones push (implementado backend, no frontend).
- ❌ Modo offline completo.

### 1.3. Estudio de la Situación Actual

#### 1.3.1. Descripción de la situación actual
El mercado de videojuegos ha crecido exponencialmente. Los jugadores utilizan múltiples plataformas para gestionar sus juegos (Steam, Epic, PSN) y otras para escuchar música (Spotify, Apple Music). No existe una herramienta centralizada que conecte eficazmente la experiencia de "jugar" con la de "escuchar la banda sonora", obligando al usuario a saltar entre aplicaciones.

#### 1.3.2. Sistemas de Información Actuales
Existen aplicaciones de catalogación como **Letterboxd** (cine) o **Backloggd** (juegos), pero se centran únicamente en el seguimiento (tracking). Por otro lado, **Spotify** tiene las bandas sonoras, pero no están vinculadas contextualmente al juego.

#### 1.3.3. Diagnóstico
*   **Problema:** Fragmentación de la información. El usuario descubre un juego en una app, pero debe ir manualmente a Spotify a buscar su música, encontrando a menudo covers no oficiales o playlists de fans.
*   **Solución Propuesta:** CheckPoint unifica estas experiencias, mostrando el álbum oficial de Spotify directamente en la ficha del juego.

### 1.4. Estudio de Alternativas de Construcción

Para el desarrollo de CheckPoint se evaluaron dos alternativas principales:

#### 1.4.1. Alternativa 1: Desarrollo Nativo (Android - Kotlin)
Desarrollo específico para Android utilizando el SDK nativo y Kotlin.
*   *Ventajas:* Máximo rendimiento, acceso directo a hardware.
*   *Desventajas:* Código no reutilizable para iOS, mayor tiempo de desarrollo, curva de aprendizaje más lenta para UI complejas.

#### 1.4.2. Alternativa 2: Desarrollo Multiplataforma (Flutter)
Desarrollo utilizando el framework Flutter (Dart) de Google.
*   *Ventajas:* Código único para Android e iOS, desarrollo de UI muy rápido (Hot Reload), rendimiento casi nativo (compila a ARM), gran ecosistema de paquetes.
*   *Desventajas:* Tamaño de la aplicación ligeramente mayor.

#### 1.4.3. Justificación de la Solución
Se ha seleccionado la **Alternativa 2 (Flutter)**.
La razón principal es la **productividad**. Como proyecto individual (TFG), Flutter permite crear una interfaz de alta calidad (Material 3) y gestionar la lógica de negocio compleja en mucho menos tiempo que el desarrollo nativo. Además, facilita la integración con Firebase y ofrece una arquitectura (Provider/Clean Arch) muy robusta para la escalabilidad.

### 1.5. Estudio de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
| :--- | :---: | :---: | :--- |
| **Límites de API (IGDB/Spotify)** | Media | Alto | Implementar caché en memoria y optimizar llamadas (ya realizado). |
| **Cambios en APIs externas** | Baja | Alto | Usar adaptadores y modelos DTO para aislar la lógica de la API externa. |
| **Conectividad a Internet** | Alta | Medio | Mostrar mensajes de error claros y permitir reintentos. |
| **Curva de aprendizaje (Clean Arch)** | Media | Medio | Seguir estrictamente la estructura de carpetas y documentación. |

---

## 2. Gestión de Proyectos

### 2.1. Metodología
Se ha utilizado una metodología ágil simplificada basada en **Scrum**. El desarrollo se ha dividido en iteraciones (Sprints) enfocadas en entregar incrementos funcionales del software.

### 2.2. Planificación (Backlog y Sprints)

> **NOTA PARA EL ALUMNO:** Completa esta sección con las fechas reales de tu desarrollo.

#### Product Backlog (Resumen)
1.  Configuración del entorno y arquitectura.
2.  Implementación de capa de datos (APIs).
3.  Sistema de Autenticación.
4.  Desarrollo de UI (Home, Detalles).
5.  Optimización y Testing.

#### Sprints

*   **Sprint 1 (Fechas):** Configuración inicial, estructura Clean Architecture y conexión básica con Firebase.
*   **Sprint 2 (Fechas):** Implementación de clientes API (IGDB, Spotify) y repositorios.
*   **Sprint 3 (Fechas):** Desarrollo de pantallas de Autenticación (Login, Registro) y lógica de controladores.
*   **Sprint 4 (Fechas):** Desarrollo de Feed Principal y Pantallas de Detalle. Integración final.

---

## 3. Análisis de Sistemas de Información (ASI)

### 3.1. Descripción General del Entorno Tecnológico

El sistema se basa en una arquitectura cliente-servidor, donde la aplicación móvil consume servicios de terceros y utiliza Backend-as-a-Service (BaaS).

**Tecnologías Principales:**
*   **Frontend:** Flutter (Dart).
*   **Backend:** Firebase (Auth, Firestore).
*   **APIs Externas:** IGDB (Videojuegos), Spotify (Música).
*   **Arquitectura:** Clean Architecture (Domain, Data, Presentation).
*   **Gestión de Estado:** Provider.

### 3.2. Catálogo de Usuarios

| Código | Nombre | Descripción |
| :--- | :--- | :--- |
| **USU1** | **Usuario Invitado** | Usuario que accede a la app sin registrarse. Tiene acceso de solo lectura al catálogo y búsquedas. |
| **USU2** | **Usuario Registrado** | Usuario autenticado. Tiene acceso completo, incluyendo biblioteca personal y perfil. |

### 3.3. Catálogo de Requisitos

#### 3.3.1. Requisitos Funcionales

| Código | Nombre | Prioridad | Descripción |
| :--- | :--- | :--- | :--- |
| **RF-01** | Registro de Usuario | Alta | Permitir crear una cuenta con email y contraseña. |
| **RF-02** | Inicio de Sesión | Alta | Validar credenciales y mantener sesión activa. |
| **RF-03** | Búsqueda de Juegos | Alta | Buscar juegos en tiempo real mediante la API de IGDB. |
| **RF-04** | Ver Detalles | Alta | Mostrar información detallada, portada y metadatos de un juego. |
| **RF-05** | Integración Spotify | Media | Mostrar y enlazar el soundtrack oficial del juego. |
| **RF-06** | Biblioteca Personal | Alta | Visualizar los juegos guardados por el usuario. |

#### 3.3.2. Requisitos No Funcionales

| Código | Nombre | Descripción |
| :--- | :--- | :--- |
| **RNF-01** | Rendimiento | La app debe mantener 60fps en transiciones y scroll. |
| **RNF-02** | Usabilidad | Interfaz basada en Material Design 3 con modo oscuro. |
| **RNF-03** | Seguridad | Las claves de API no deben estar expuestas (uso de .env). |
| **RNF-04** | Disponibilidad | La app debe manejar errores de red sin cerrarse inesperadamente. |

#### 3.3.3. Requisitos de Información (Datos)

*   **Usuario:** ID, email, nombre, fotoURL.
*   **Juego:** ID (IGDB), título, portada, rating, año, géneros, plataformas.
*   **Soundtrack:** ID (Spotify), nombre, artista, portada, URL.

### 3.4. Modelo de Casos de Uso

#### 3.4.1. Diagrama de Casos de Uso
*(Se recomienda incluir imagen del diagrama UML aquí)*

#### 3.4.2. Especificación de Casos de Uso (Resumen)

**CU-01: Consultar Feed (Inicio)**
*   **Actor:** Usuario (Todos).
*   **Flujo:** El sistema carga juegos populares de IGDB y soundtracks de Spotify. Si hay error, muestra aviso. Si hay éxito, muestra carruseles horizontales.

**CU-02: Buscar Videojuego**
*   **Actor:** Usuario (Todos).
*   **Flujo:** Usuario introduce texto (>3 caracteres). Sistema consulta IGDB. Muestra lista de resultados.

**CU-03: Ver Detalle de Juego**
*   **Actor:** Usuario (Todos).
*   **Flujo:** Usuario toca una tarjeta de juego. Sistema navega a pantalla de detalle, carga info extendida y busca soundtrack asociado.

**CU-04: Gestionar Biblioteca**
*   **Actor:** Usuario Registrado.
*   **Flujo:** Usuario accede a pestaña Biblioteca. Sistema recupera lista de IDs de Firestore y muestra los juegos.

### 3.5. Interfaces de Usuario

La interfaz se ha diseñado para ser intuitiva y familiar (patrones estándar de Android).

*   **Pantalla de Bienvenida:** Punto de entrada. Ofrece Login, Registro o modo Invitado.
*   **Home (Feed):** Pantalla principal. Muestra novedades y tendencias. Utiliza scroll vertical con secciones horizontales.
*   **Detalle (Juego/Soundtrack):** Cabecera con imagen grande ("DetailHeader"), información clave, y secciones expandibles.
*   **Navegación:** Barra de navegación inferior (BottomNavigationBar) persistente para cambio rápido entre secciones principales.

---
