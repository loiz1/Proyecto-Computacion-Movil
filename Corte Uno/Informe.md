# 📦 Sistema de Gestión y Análisis de Despachos - Documentación Completa

## 📋 Tabla de Contenidos
1. [Informe Ejecutivo](#informe-ejecutivo)
2. [Requisitos Funcionales](#requisitos-funcionales)
3. [Requisitos Técnicos](#requisitos-tecnicos)
4. [Alcance del Proyecto](#alcance-del-proyecto)
5. [Plan de Desarrollo](#plan-de-desarrollo)

---

## 1. Informe Ejecutivo {#informe-ejecutivo}

### 1.1 Resumen del Proyecto
Sistema web de gestión y análisis de despachos de mercancía para toda Colombia. Permite visualizar, analizar y gestionar información sobre cajas, peso, costo, volumen y clientes mediante dashboards interactivos.

### 1.2 Objetivo Principal
Desarrollar una aplicación web que permita medir y analizar la totalidad de mercancía despachada hacia toda Colombia, proporcionando visualizaciones gráficas y herramientas de análisis para la toma de decisiones.

### 1.3 Alcance
- **Fase**: Proyecto piloto/prueba
- **Usuarios concurrentes esperados**: 10
- **Disponibilidad**: Entorno de pruebas
- **Escalabilidad**: Limitada a fase de prueba

### 1.4 Beneficios Esperados
- Visualización centralizada de datos de despachos
- Análisis en tiempo real de métricas clave
- Gestión eficiente de información por roles
- Filtrado dinámico de información por cliente, ciudad y fechas

---

## 2. Requisitos Funcionales {#requisitos-funcionales}

### 2.1 Módulos del Sistema

#### 2.1.1 Dashboard de Gráficos
**Descripción**: Panel principal de visualización de datos

**Funcionalidades**:
- Visualización de gráficos de barras
- Visualización de gráficos de líneas
- Visualización de gráficos circulares
- Filtros por:
  - Cliente
  - Ciudad
  - Fechas (rango)

**Métricas visualizadas**:
- Cantidad de cajas despachadas
- Peso total
- Costo total
- Volumen total
- Distribución por cliente
- Distribución por ciudad

**Interacciones permitidas**:
- Visualización de gráficos
- Aplicación de filtros
- Solo lectura (no edición)

#### 2.1.2 Dashboard de Ingreso de Datos
**Descripción**: Panel para carga de información

**Funcionalidades**:
- Campo de carga de archivo
- Botón de submit para procesar datos
- Validación de formato de archivo
- Confirmación de carga exitosa

**Tipos de archivo aceptados**: (Por definir - CSV, Excel, etc.)

#### 2.1.3 Panel de Configuración
**Descripción**: Panel de configuración personal del usuario

**Funcionalidades**:
- Visualización de información del usuario
- Foto de perfil
- Cambio de contraseña
- Datos personales

#### 2.1.4 Panel de Gestión de Usuarios
**Descripción**: Panel administrativo de usuarios (solo Admin)

**Funcionalidades**:
- Crear nuevos usuarios
- Modificar usuarios existentes
- Eliminar usuarios
- Asignar roles
- Gestionar permisos

### 2.2 Sistema de Roles y Permisos

#### 2.2.1 Rol Administrador
**Permisos**:
- ✅ Crear usuarios
- ✅ Modificar usuarios
- ✅ Eliminar usuarios
- ✅ Agregar datos (cargar archivos)
- ✅ Ver dashboards (todos los gráficos)
- ✅ Acceder a configuración personal
- ✅ Acceder a panel de usuarios

#### 2.2.2 Rol Analista
**Permisos**:
- ✅ Agregar datos (cargar archivos)
- ✅ Ver dashboards (todos los gráficos)
- ✅ Acceder a configuración personal
- ❌ Gestionar usuarios

#### 2.2.3 Rol Normal
**Permisos**:
- ✅ Ver dashboards (solo visualización)
- ✅ Acceder a configuración personal
- ❌ Agregar datos
- ❌ Gestionar usuarios

### 2.3 Sistema de Autenticación
- **Login con credenciales** (usuario y contraseña)
- **Tokens JWT** para sesiones
- **No se requiere** recuperación de contraseña (fase inicial)
- **No hay integración** con sistemas de autenticación externos

---

## 3. Requisitos Técnicos {#requisitos-tecnicos}

### 3.1 Arquitectura del Sistema

#### 3.1.1 Frontend
**Tecnología**: React Native (Web)

**Características**:
- Interfaz responsiva
- Componentes reutilizables
- Gestión de estado (Redux/Context API)
- Integración con biblioteca de gráficos (Recharts/Chart.js)

**Estructura propuesta**:
```
src/
├── components/
│   ├── common/
│   ├── dashboard/
│   ├── users/
│   └── auth/
├── pages/
│   ├── Login.jsx
│   ├── Dashboard.jsx
│   ├── DataUpload.jsx
│   ├── Users.jsx
│   └── Configuration.jsx
├── services/
│   └── api.js
├── utils/
├── styles/
└── App.jsx
```

#### 3.1.2 Backend
**Tecnología**: Python con Flask/Django REST Framework

**Características**:
- API RESTful
- Autenticación JWT
- Validación de datos
- Manejo de archivos
- Procesamiento de datos

**Estructura de API REST**:

**Endpoints de Autenticación**:
```
POST /api/auth/login
POST /api/auth/logout
POST /api/auth/refresh
```

**Endpoints de Usuarios** (Admin):
```
GET    /api/users
GET    /api/users/{id}
POST   /api/users
PUT    /api/users/{id}
DELETE /api/users/{id}
```

**Endpoints de Datos**:
```
POST   /api/data/upload
GET    /api/data/shipments
GET    /api/data/statistics
```

**Endpoints de Dashboard**:
```
GET /api/dashboard/charts
GET /api/dashboard/filters
```

**Endpoints de Configuración**:
```
GET /api/config/profile
PUT /api/config/profile
PUT /api/config/password
```

#### 3.1.3 Base de Datos
**Tecnología**: MySQL

**Esquema de Base de Datos**:

**Tabla: users**
```sql
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin', 'analista', 'normal') NOT NULL,
    profile_photo VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);
```

**Tabla: shipments (despachos)**
```sql
CREATE TABLE shipments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT NOT NULL,
    city_id INT NOT NULL,
    num_boxes INT NOT NULL,
    weight_kg DECIMAL(10,2) NOT NULL,
    cost DECIMAL(12,2) NOT NULL,
    volume_m3 DECIMAL(10,3) NOT NULL,
    shipment_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    uploaded_by INT,
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (city_id) REFERENCES cities(id),
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);
```

**Tabla: clients**
```sql
CREATE TABLE clients (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Tabla: cities**
```sql
CREATE TABLE cities (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Tabla: data_uploads (historial de cargas)**
```sql
CREATE TABLE data_uploads (
    id INT PRIMARY KEY AUTO_INCREMENT,
    filename VARCHAR(255) NOT NULL,
    uploaded_by INT NOT NULL,
    rows_processed INT,
    status ENUM('pending', 'completed', 'failed') DEFAULT 'pending',
    error_message TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (uploaded_by) REFERENCES users(id)
);
```

### 3.2 Requisitos No Funcionales

#### 3.2.1 Rendimiento
- **Usuarios concurrentes**: 10
- **Tiempo de respuesta**: < 2 segundos para consultas
- **Carga de gráficos**: < 3 segundos
- **Procesamiento de archivos**: Depende del tamaño

#### 3.2.2 Seguridad
- Autenticación mediante JWT
- Hashing de contraseñas (bcrypt)
- Validación de entrada de datos
- Protección contra SQL Injection
- HTTPS en producción
- Control de acceso basado en roles (RBAC)

#### 3.2.3 Escalabilidad
- **Fase actual**: Prueba/piloto
- **Diseño**: Preparado para escalar
- **Limitaciones**: Sin optimizaciones de alto rendimiento

#### 3.2.4 Disponibilidad
- **Entorno**: Pruebas
- **SLA**: No crítico
- **Backups**: Recomendados pero no obligatorios

---

## 4. Alcance del Proyecto {#alcance-del-proyecto}

### 4.1 En Alcance (Incluido)

#### 4.1.1 Funcionalidades Core
✅ Sistema de autenticación con JWT
✅ Dashboard de visualización con gráficos (barras, líneas, circulares)
✅ Filtros por cliente, ciudad y fechas
✅ Panel de carga de datos (archivos)
✅ Gestión de usuarios (CRUD completo)
✅ Sistema de roles (Admin, Analista, Normal)
✅ Panel de configuración personal
✅ Base de datos MySQL con esquema completo

#### 4.1.2 Métricas y Análisis
✅ Medición de cajas despachadas
✅ Medición de peso total
✅ Medición de costo total
✅ Medición de volumen total
✅ Distribución por cliente
✅ Distribución por ciudad

### 4.2 Fuera de Alcance (Excluido)

#### 4.2.1 Funcionalidades No Incluidas
❌ Recuperación de contraseña
❌ Integración con sistemas externos de autenticación
❌ Notificaciones por email
❌ Exportación de reportes a PDF/Excel
❌ Versión móvil nativa
❌ Modo offline
❌ Análisis predictivo con IA/ML
❌ Integración con APIs externas
❌ Sistema de auditoría avanzado

#### 4.2.2 Optimizaciones No Incluidas
❌ Optimización para miles de usuarios concurrentes
❌ CDN para contenido estático
❌ Cache distribuido
❌ Load balancing
❌ Alta disponibilidad (HA)

### 4.3 Supuestos y Restricciones

#### 4.3.1 Supuestos
- Los archivos de datos vendrán en formato estructurado
- Los usuarios tendrán acceso a navegadores modernos
- La conexión a internet será estable
- Los datos no requerirán procesamiento complejo en tiempo real

#### 4.3.2 Restricciones
- Presupuesto limitado (fase de prueba)
- Equipo de desarrollo: 1 persona
- Tiempo de desarrollo: A definir en planificación
- Infraestructura: Servidor básico

---

## 5. Plan de Desarrollo {#plan-de-desarrollo}

### 5.1 Metodología Ágil - Scrum

#### 5.1.1 Roles del Proyecto
- **Product Owner**: Yo (define prioridades y requisitos)
- **Scrum Master**: Yo (facilita el proceso Scrum)
- **Equipo de Desarrollo**: Yo (desarrolla el producto)

#### 5.1.2 Ceremonias Scrum Adaptadas
- **Sprint Planning**: Planificación individual semanal
- **Daily Stand-up**: Revisión diaria personal de progreso
- **Sprint Review**: Revisión de entregables al final del sprint
- **Sprint Retrospective**: Reflexión sobre mejoras del proceso

### 5.2 Product Backlog (Priorizadas)

#### Sprint 1 - Fundamentos (Prioridad: Alta)
**Duración estimada**: 2 semanas

**User Stories**:
1. **US-001**: Como desarrollador, necesito configurar el entorno de desarrollo (Frontend + Backend + Base de Datos)
   - Estimación: 8 horas
   - Prioridad: Alta

2. **US-002**: Como desarrollador, necesito diseñar e implementar el esquema de base de datos
   - Estimación: 6 horas
   - Prioridad: Alta

3. **US-003**: Como usuario, necesito poder iniciar sesión en el sistema
   - Estimación: 12 horas
   - Prioridad: Alta
   - Criterios de aceptación:
     - Login con usuario y contraseña
     - Generación de token JWT
     - Redirección según rol

4. **US-004**: Como desarrollador, necesito implementar el sistema de autenticación JWT
   - Estimación: 10 horas
   - Prioridad: Alta

#### Sprint 2 - Gestión de Usuarios (Prioridad: Alta)
**Duración estimada**: 2 semanas

**User Stories**:
5. **US-005**: Como administrador, necesito crear nuevos usuarios
   - Estimación: 8 horas
   - Prioridad: Alta
   - Criterios de aceptación:
     - Formulario de creación
     - Validación de datos
     - Asignación de roles

6. **US-006**: Como administrador, necesito visualizar la lista de usuarios
   - Estimación: 6 horas
   - Prioridad: Alta

7. **US-007**: Como administrador, necesito editar usuarios existentes
   - Estimación: 6 horas
   - Prioridad: Alta

8. **US-008**: Como administrador, necesito eliminar usuarios
   - Estimación: 4 horas
   - Prioridad: Alta

9. **US-009**: Como usuario, necesito acceder a mi panel de configuración
   - Estimación: 8 horas
   - Prioridad: Media
   - Criterios de aceptación:
     - Ver perfil
     - Cambiar contraseña
     - Subir foto de perfil

#### Sprint 3 - Carga y Gestión de Datos (Prioridad: Alta)
**Duración estimada**: 2 semanas

**User Stories**:
10. **US-010**: Como analista/admin, necesito cargar archivos con datos de despachos
    - Estimación: 12 horas
    - Prioridad: Alta
    - Criterios de aceptación:
      - Seleccionar archivo
      - Validar formato
      - Procesar y guardar datos
      - Mostrar confirmación

11. **US-011**: Como desarrollador, necesito crear el parser de archivos de datos
    - Estimación: 10 horas
    - Prioridad: Alta

12. **US-012**: Como desarrollador, necesito implementar validaciones de datos
    - Estimación: 8 horas
    - Prioridad: Alta

13. **US-013**: Como sistema, necesito registrar el historial de cargas de datos
    - Estimación: 6 horas
    - Prioridad: Media

#### Sprint 4 - Dashboard de Visualización Básico (Prioridad: Alta)
**Duración estimada**: 2 semanas

**User Stories**:
14. **US-014**: Como usuario, necesito ver el dashboard principal con gráficos
    - Estimación: 16 horas
    - Prioridad: Alta
    - Criterios de aceptación:
      - Visualizar datos en pantalla
      - Layout responsive
      - Diseño intuitivo

15. **US-015**: Como usuario, necesito ver gráficos de barras con las métricas
    - Estimación: 10 horas
    - Prioridad: Alta

16. **US-016**: Como usuario, necesito ver gráficos de líneas temporales
    - Estimación: 8 horas
    - Prioridad: Alta

17. **US-017**: Como usuario, necesito ver gráficos circulares de distribución
    - Estimación: 8 horas
    - Prioridad: Alta

#### Sprint 5 - Filtros y Análisis (Prioridad: Media)
**Duración estimada**: 2 semanas

**User Stories**:
18. **US-018**: Como usuario, necesito filtrar datos por cliente
    - Estimación: 8 horas
    - Prioridad: Media
    - Criterios de aceptación:
      - Dropdown de clientes
      - Actualización de gráficos
      - Múltiple selección

19. **US-019**: Como usuario, necesito filtrar datos por ciudad
    - Estimación: 8 horas
    - Prioridad: Media

20. **US-020**: Como usuario, necesito filtrar datos por rango de fechas
    - Estimación: 10 horas
    - Prioridad: Media

21. **US-021**: Como usuario, necesito combinar múltiples filtros
    - Estimación: 6 horas
    - Prioridad: Media

22. **US-022**: Como usuario, necesito limpiar todos los filtros aplicados
    - Estimación: 4 horas
    - Prioridad: Baja

#### Sprint 6 - Pulimiento y Testing (Prioridad: Media)
**Duración estimada**: 1-2 semanas

**User Stories**:
23. **US-023**: Como desarrollador, necesito implementar tests unitarios críticos
    - Estimación: 12 horas
    - Prioridad: Media

24. **US-024**: Como desarrollador, necesito implementar tests de integración
    - Estimación: 10 horas
    - Prioridad: Media

25. **US-025**: Como usuario, necesito una interfaz pulida y responsive
    - Estimación: 16 horas
    - Prioridad: Media

26. **US-026**: Como desarrollador, necesito optimizar el rendimiento de consultas
    - Estimación: 8 horas
    - Prioridad: Baja

27. **US-027**: Como administrador, necesito documentación de usuario
    - Estimación: 8 horas
    - Prioridad: Baja

### 5.3 Cronograma del Proyecto

**FASE 1 - PLANEACIÓN Y DISEÑO**: 03 de noviembre al 23 de noviembre (3 semanas)
- Documentación completa
- Wireframes
- Mockups
- Diseño de UI/UX
- Definición de arquitectura

**FASE 2 - DESARROLLO**: 24 de noviembre al 09 de diciembre (2.5 semanas)

### 5.4 Estimación de Esfuerzo Total

| Sprint | Historias | Horas Estimadas | Semanas |
|--------|-----------|-----------------|---------|
| Sprint 1 | 4 | 36h | 0.5 |
| Sprint 2 | 5 | 32h | 0.5 |
| Sprint 3 | 4 | 36h | 0.5 |
| Sprint 4 | 4 | 42h | 0.5 |
| Sprint 5 | 5 | 36h | 0.5 |
| Sprint 6 | 5 | 54h | 0.5 |
| **TOTAL** | **27** | **236h** | **2.5 semanas** |

**Nota**: Desarrollo intensivo de 2.5 semanas. Se requiere dedicación de tiempo completo para cumplir los plazos.

### 5.4 Definición de Hecho (Definition of Done)

Una historia de usuario se considera "Hecha" cuando:

- ✅ Código desarrollado y funcional
- ✅ Código versionado en Git
- ✅ Tests básicos implementados
- ✅ Documentación del código actualizada
- ✅ Funcionalidad probada manualmente
- ✅ Sin bugs críticos conocidos
- ✅ Cumple los criterios de aceptación
- ✅ Revisión personal completada

### 5.5 Planificación de Sprints

#### FASE 1: Planeación y Diseño (3 semanas)
**Del 03 al 23 de noviembre de 2025**

**Semana 1 (03-09 Nov)**:
- ✅ Documentación completa del proyecto
- Análisis de requisitos detallado
- Definición de arquitectura

**Semana 2 (10-16 Nov)**:
- Wireframes de todas las pantallas
- Flujos de usuario
- Definición de componentes

**Semana 3 (17-23 Nov)**:
- Mockups de alta fidelidad
- Guía de estilos
- Assets y recursos visuales
- Preparación del entorno de desarrollo

---

#### FASE 2: Desarrollo (2.5 semanas intensivas)
**Del 24 de noviembre al 09 de diciembre de 2025**

**Días 1-3 (24-26 Nov)**: Sprint 1 - Fundamentos
- Configuración de entornos
- Base de datos
- Autenticación básica

**Días 4-6 (27-29 Nov)**: Sprint 2 - Gestión de Usuarios
- CRUD de usuarios
- Panel de configuración

**Días 7-9 (30 Nov - 02 Dic)**: Sprint 3 - Carga de Datos
- Upload de archivos
- Procesamiento de datos

**Días 10-12 (03-05 Dic)**: Sprint 4 - Dashboard Básico
- Implementación de gráficos
- Visualización de datos

**Días 13-15 (06-08 Dic)**: Sprint 5 - Filtros
- Filtros dinámicos
- Interacciones del dashboard

**Día 16 (09 Dic)**: Sprint 6 - Pulimiento Final
- Testing crítico
- Ajustes finales
- Entrega

### 5.6 Reuniones y Ceremonias

#### Daily Stand-up Personal (15 min diarios)
**Preguntas guía**:
1. ¿Qué hice ayer?
2. ¿Qué haré hoy?
3. ¿Hay impedimentos?

#### Sprint Planning (2h al inicio de cada sprint)
**Actividades**:
- Revisar Product Backlog
- Seleccionar historias para el sprint
- Estimar esfuerzo
- Definir objetivo del sprint

#### Sprint Review (1h al final de cada sprint)
**Actividades**:
- Demostración de funcionalidades
- Validación de criterios de aceptación
- Registro de feedback

#### Sprint Retrospective (1h al final de cada sprint)
**Preguntas guía**:
1. ¿Qué salió bien?
2. ¿Qué se puede mejorar?
3. ¿Qué acciones tomar?

### 5.7 Herramientas de Gestión

**Control de Versiones**:
- Git + GitHub/GitLab

**Gestión de Tareas**:
- Trello / Jira / Notion
- Tablero Kanban con columnas:
  - Backlog
  - To Do
  - In Progress
  - Testing
  - Done

**Documentación**:
- Markdown para documentación técnica
- Comentarios en código
- README actualizado

### 5.8 Registro de Progreso

**Documentar en cada sprint**:
- Velocidad del sprint (historias completadas)
- Horas reales vs estimadas
- Problemas encontrados y soluciones
- Decisiones técnicas importantes
- Lecciones aprendidas

**Formato de Registro**:
```markdown
## Sprint X - [Nombre]
**Fecha**: DD/MM/YYYY - DD/MM/YYYY
**Objetivo**: [Descripción]

### Historias Completadas
- [x] US-XXX: Descripción (Horas: estimadas/reales)

### Problemas Encontrados
- Problema 1: [Descripción y solución]

### Decisiones Técnicas
- Decisión 1: [Descripción y justificación]

### Lecciones Aprendidas
- Lección 1: [Descripción]

### Próximos Pasos
- Acción 1
- Acción 2
```

---

## 6. Anexos

### 6.1 Glosario de Términos

- **Dashboard**: Panel de control visual
- **JWT**: JSON Web Token (sistema de autenticación)
- **CRUD**: Create, Read, Update, Delete
- **API REST**: Interfaz de programación de aplicaciones basada en REST
- **Sprint**: Iteración de desarrollo (1-2 semanas)
- **User Story**: Historia de usuario que describe una funcionalidad

### 6.2 Referencias Técnicas

**React Native**:
- Documentación oficial: https://reactnative.dev/

**Flask**:
- Documentación oficial: https://flask.palletsprojects.com/

**Django REST Framework**:
- Documentación oficial: https://www.django-rest-framework.org/

**MySQL**:
- Documentación oficial: https://dev.mysql.com/doc/

### 6.3 Contacto y Soporte

**Desarrollador**: [Tu Nombre]
**Email**: [Tu Email]
**Repositorio**: [URL del repositorio Git]

---

**Fecha de creación**: 03/11/2025
**Última actualización**: 09/11/2025
**Versión**: 1.0

**Fechas del Proyecto**:
- **Fase 1 - Planeación y Diseño**: 03/11/2025 - 23/11/2025
- **Fase 2 - Desarrollo**: 24/11/2025 - 09/12/2025