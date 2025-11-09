# 📦 Sistema de Gestión y Análisis de Despachos

Aplicacion en Android para la gestión y análisis de despachos de mercancía a nivel nacional. Permite visualizar, analizar y gestionar información sobre cajas, peso, costo, volumen y clientes mediante dashboards interactivos con gráficos y filtros dinámicos.


## ✨ Características

### Dashboard de Visualización
- 📊 Gráficos de barras, líneas y circulares
- 🔍 Filtros por cliente, ciudad y fechas
- 📈 Métricas en tiempo real (cajas, peso, costo, volumen)
- 📱 Interfaz responsive

### Gestión de Datos
- 📁 Carga de archivos con datos de despachos
- ✅ Validación automática de datos
- 📝 Historial de cargas
- 🔄 Procesamiento de datos en lote

### Sistema de Usuarios
- 👥 Gestión completa de usuarios (CRUD)
- 🔐 Autenticación con JWT
- 🎭 3 roles: Administrador, Analista, Normal
- ⚙️ Panel de configuración personal

### Seguridad
- 🔒 Autenticación mediante JWT
- 🛡️ Control de acceso basado en roles (RBAC)
- 🔑 Hashing de contraseñas con bcrypt
- 🚫 Protección contra SQL Injection

---

## 📁 Estructura del Proyecto

```
proyecto-despachos/
│
├── 01-Documentacion/          # Documentación del proyecto
│   ├── README.md
│   ├── Informe-Ejecutivo.md
│   ├── Requisitos-Funcionales.md
│   ├── Requisitos-Tecnicos.md
│   ├── Alcance-del-Proyecto.md
│   └── Plan-de-Desarrollo.md
│
├── 02-Diseno/                 # Wireframes y mockups
│   ├── wireframes/
│   └── mockups/
│
└── 03-Desarrollo/             # Código fuente
    ├── backend/
    │   ├── app/
    │   │   ├── models/
    │   │   ├── routes/
    │   │   ├── services/
    │   │   └── utils/
    │   ├── config/
    │   ├── tests/
    │   └── requirements.txt
    │
    ├── frontend/
    │   ├── src/
    │   │   ├── components/
    │   │   ├── pages/
    │   │   ├── services/
    │   │   ├── utils/
    │   │   └── styles/
    │   ├── public/
    │   └── package.json
    │
    └── database/
        ├── migrations/
        └── seeds/
```


---


## 📅 Cronograma

### Fase 1: Planeación y Diseño
**📆 03/11/2025 - 23/11/2025** (3 semanas)

| Semana | Actividades | Estado |
|--------|-------------|--------|
| 1 (03-09 Nov) | Documentación completa | ✅ Completado |
| 2 (10-16 Nov) | Wireframes y flujos | 🔄 En progreso |
| 3 (17-23 Nov) | Mockups y guía de estilos | ⏳ Pendiente |

### Fase 2: Desarrollo
**📆 24/11/2025 - 09/12/2025** (2.5 semanas)

| Sprint | Días | Funcionalidad | Estado |
|--------|------|---------------|--------|
| 1 | 24-26 Nov | Fundamentos y autenticación | ⏳ Pendiente |
| 2 | 27-29 Nov | Gestión de usuarios | ⏳ Pendiente |
| 3 | 30 Nov-02 Dic | Carga de datos | ⏳ Pendiente |
| 4 | 03-05 Dic | Dashboard de gráficos | ⏳ Pendiente |
| 5 | 06-08 Dic | Filtros e interacciones | ⏳ Pendiente |
| 6 | 09 Dic | Pulimiento y entrega | ⏳ Pendiente |



**Última actualización**: 09/11/2025  
**Versión**: 1.0.0  
**Estado**: 🟡 En Desarrollo - Fase de Planeación

-