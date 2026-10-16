# Informe del Proyecto GreenFix

**Plataforma de Micro-Crowdfunding Descentralizado**

---

## Resumen Ejecutivo

GreenFix es una plataforma descentralizada que permite a pequeños negocios obtener financiamiento directamente de inversores, sin intermediarios bancarios, utilizando tecnología blockchain. El sistema funciona como un punto de encuentro donde emprendedores publican sus proyectos, los inversores aportan capital a cambio de un retorno con intereses, y contratos inteligentes garantizan que todo el proceso sea transparente, automático y seguro.

Este documento describe qué se construyó, cómo funciona, y qué tecnologías se utilizaron para desarrollar el MVP (Producto Mínimo Viable).

---

## 1. ¿Qué problema resuelve GreenFix?

Los pequeños negocios enfrentan barreras para acceder a créditos tradicionales: papeleo excesivo, tasas altas, falta de historial crediticio. Por otro lado, personas comunes quieren invertir pero no tienen acceso a oportunidades más allá de instrumentos financieros tradicionales.

GreenFix propone una alternativa: **conectar directamente a quien necesita capital con quien quiere invertir**, eliminando intermediarios y usando blockchain como garantía de transparencia. Todo el dinero se maneja mediante contratos inteligentes que nadie puede modificar unilateralmente.

---

## 2. Objetivo del MVP

El Producto Mínimo Viable debía demostrar el ciclo completo del protocolo:

1. Un emprendedor crea un proyecto, define cuánto necesita y deposita una garantía del 5%
2. Inversores financian el proyecto hasta alcanzar la meta exacta
3. El capital se libera por etapas (hitos o milestones) según el emprendedor demuestre avances
4. Los inversores votan para aprobar o rechazar cada liberación de fondos
5. El emprendedor devuelve el préstamo con intereses en cuotas
6. Los inversores reclaman su capital más ganancias al finalizar

Este flujo completo se implementó y se probó exitosamente en un entorno 100% local.

---

## 3. Arquitectura del Sistema

GreenFix sigue un modelo **híbrido**: parte de la información vive en la blockchain (la verdad financiera) y otra parte en una base de datos tradicional (metadata, historial, estadísticas).

```
┌──────────────────────────────────────────────┐
│                  USUARIO                      │
│         (Navegador + MetaMask)                │
└──────────────┬───────────────┬────────────────┘
               │               │
               ▼               ▼
     ┌─────────────┐   ┌──────────────┐
     │   FRONTEND   │   │   BACKEND    │
     │   React 19   │◄──│  .NET 10     │
     │   ethers.js  │   │  EF Core     │
     └──────┬───────┘   └──────┬───────┘
            │                  │
            ▼                  ▼
   ┌─────────────────┐  ┌──────────────┐
   │  HARDHAT NODE   │  │  SQL SERVER  │
   │  Smart Contracts │  │  Metadata +  │
   │  (verdad fin.)   │  │  Auditoría   │
   └─────────────────┘  └──────────────┘
```

### ¿Por qué dos fuentes de datos?

- **Blockchain**: almacena lo que no puede mentir: cuánto dinero hay, quién invirtió, en qué estado está el proyecto, los votos. Es inmutable y cualquiera puede verificarlo.
- **Base de datos**: guarda lo que sería muy costoso o imposible almacenar en blockchain: nombres de proyectos, descripciones, imágenes, historial de auditoría, estadísticas.

Si el backend se apaga, el frontend **sigue funcionando** porque la blockchain es la fuente de verdad. El backend solo enriquece la experiencia con metadata.

---

## 4. Los Contratos Inteligentes (Blockchain)

El corazón del sistema son tres contratos programados en **Solidity**, el lenguaje de Ethereum:

### 4.1 GreenFixFactory

La fábrica de proyectos. Cuando un emprendedor crea un proyecto, este contrato despliega una instancia nueva y la registra en un listado global.

- **105 líneas de código**
- Cada proyecto obtiene un ID único secuencial
- La garantía exigida es del 5% del monto solicitado

### 4.2 GreenFixProject

El contrato principal. Cada proyecto tiene el suyo propio, independiente. Contiene:

- **Estructura de datos**: configuración del proyecto, milestones, cuotas de pago
- **Máquina de estados**: 7 estados por los que pasa el proyecto durante su vida
- **Lógica financiera**: inversión, liberación de fondos, pagos, reembolsos, recompensas
- **Sistema de votación**: cada inversor vota con un peso proporcional a su inversión (1 USDC = 1 voto)
- **711 líneas de código** — es el componente más complejo del sistema

### 4.3 ProjectToken

Un token no transferible que representa la participación de cada inversor. Solo se puede crear (mint) al invertir y destruir (burn) al reclamar. Esto evita especulación y compra de votos.

### Máquina de Estados del Proyecto

Cada proyecto sigue un ciclo de vida estricto:

```
Funding  →  Active  →  Voting  →  Active  (ciclo por cada hito)
   ↓          ↓          ↓
Cancelled  Completed  Defaulted → Refunding
```

Esto garantiza que el contrato siempre esté en un estado válido y predecible. Todas las funciones verifican el estado actual antes de ejecutarse.

---

## 5. Frontend (Aplicación Web)

Construido con **React 19** y **Tailwind CSS**, conectado directamente a la blockchain mediante **ethers.js v6**.

### Vistas principales:

| Vista | Descripción |
|---|---|
| **Home** | Landing page con explicación del protocolo |
| **Dashboard** | Lista de proyectos con filtro por rol (inversor ve todo, emprendedor ve sus propios proyectos) |
| **Crear Proyecto** | Formulario con validación de wallet y KYC simulado |
| **Detalle de Proyecto** | Panel completo: inversión, milestones con votación, cuotas de pago, reclamos |

### Funcionalidades implementadas:

- Conexión con MetaMask (detección automática de red Hardhat)
- Faucet de USDC de prueba (5000 USDC por click)
- Inversión directa desde wallet
- Votación con peso proporcional al capital invertido
- Liberación de fondos por hitos aprobados
- Sistema de cuotas de pago para el emprendedor
- Reclamo de recompensas (capital + intereses)
- Reembolso proporcional en caso de cancelación o default

---

## 6. Backend (API REST)

Desarrollado en **C# .NET 10** con **Entity Framework Core 8** y **SQL Server**.

### Funciones del backend:

- **Metadata de proyectos**: nombre, descripción, imagen (lo que no va en blockchain)
- **Auditoría**: registro de cada cambio de estado de los proyectos (trigger automático en BD)
- **Estadísticas**: funciones SQL para consultar totales, porcentajes y métricas globales
- **Self-heal**: al arrancar, el backend detecta si faltan columnas en la base de datos y las agrega automáticamente

### Endpoints principales:

| Recurso | Operaciones |
|---|---|
| `api/proyectos` | CRUD + búsqueda por estado y dirección de contrato |
| `api/usuarios` | Registro y consulta |
| `api/inversiones` | Registro de aportes |
| `api/milestones` | Gestión de hitos |
| `api/votos` | Registro de votaciones |
| `api/pagos` | Gestión de cuotas |
| `api/recompensas` | Reclamo de ganancias |
| `api/reembolsos` | Registro de reembolsos |

---

## 7. Base de Datos

### Tablas del sistema:

| Tabla | Propósito |
|---|---|
| `Usuarios` | Emprendedores e inversores |
| `Proyectos` | Metadata de cada proyecto + dirección del contrato |
| `Inversiones` | Registro de cada aporte |
| `Milestones` | Hitos del proyecto |
| `Votos` | Historial de votaciones |
| `Pagos` | Cuotas de devolución del préstamo |
| `Reembolsos` | Devoluciones en caso de cancelación/default |
| `Recompensas` | Ganancias reclamadas por inversores |
| `Evidencias` | Documentos subidos por el emprendedor |
| `AuditoriaProyectos` | Bitácora automática de cambios de estado |

### Lógica de base de datos implementada:

- **4 funciones SQL** para estadísticas rápidas (total recaudado, porcentaje financiado, número de inversores, métricas globales)
- **3 procedimientos almacenados** para registro atómico, actualización de estado e historial de auditoría
- **1 trigger** que registra automáticamente cada cambio de estado de un proyecto en la tabla de auditoría

---

## 8. Pruebas Realizadas

Se escribieron **38 pruebas automatizadas** que cubren los escenarios principales:

| Categoría | Pruebas | ¿Qué validan? |
|---|---|---|
| **Funding** | 8 | Crear proyecto, depositar garantía, invertir, cancelar, finalizar recaudación |
| **Milestones** | 11 | Solicitar liberación, votar a favor/en contra, finalizar votación, doble rechazo lleva a default |
| **Refunds** | 7 | Activar reembolsos, calcular montos, reclamar, prevenir doble reclamo, snapshot anti-manipulación |
| **Repayments** | 5 | Pagar cuotas, prevenir doble pago, completar proyecto, reclamar recompensas, declarar default |
| **Integración** | 7 | Pruebas end-to-end con ethers.js simulando el flujo real del usuario |

---

## 9. Flujo de Demostración

El sistema está configurado para ejecutarse 100% en local. El flujo de demo típico es:

1. **Iniciar nodo blockchain local** (simula Ethereum en tu máquina)
2. **Desplegar contratos** (se crean USDC de prueba y se reparten a cuentas de prueba)
3. **Iniciar backend** (API REST + conexión a SQL Server)
4. **Iniciar frontend** (aplicación React accesible en el navegador)

Una vez todo en marcha:

- El **negociador** conecta su wallet, crea un proyecto y deposita la garantía
- El **inversor** explora los proyectos disponibles e invierte
- Cuando se alcanza la meta, el negociador **finaliza la recaudación** y se generan los hitos
- El negociador **solicita liberación** de cada hito subiendo evidencia
- Los inversores **votan** (el peso del voto es proporcional a lo invertido)
- Si se aprueba, los fondos se liberan automáticamente al negociador
- El negociador **paga las cuotas** del préstamo
- Al completar todos los pagos, los inversores **reclaman sus ganancias** (capital + intereses)

---

## 10. Stack Tecnológico Completo

| Capa | Tecnología | Versión |
|---|---|---|
| **Frontend** | React + Vite | 19 / 8 |
| **Estilos** | Tailwind CSS | 4 |
| **Blockchain** | ethers.js | 6.16 |
| **Smart Contracts** | Solidity + Hardhat | 0.8.28 / 3 Beta |
| **Librerías BC** | OpenZeppelin | 5.2 |
| **Backend** | .NET + ASP.NET Core | 10 |
| **ORM** | Entity Framework Core | 8 |
| **Base de Datos** | SQL Server | - |
| **Animaciones** | Framer Motion | 12 |
| **Íconos** | Lucide React | 1.16 |

---

## 11. Métricas del Proyecto

| Indicador | Cantidad |
|---|---|
| Líneas de código Solidity | ~1,100 |
| Líneas de código C# | ~700 |
| Líneas de código JavaScript/JSX | ~2,400 |
| Líneas de código SQL | ~420 |
| **Total líneas de código** | **~4,620** |
| Contratos inteligentes | 3 principales + 3 interfaces + 2 librerías |
| Pruebas automatizadas | 38 |
| Endpoints de API | 28 |
| Tablas de base de datos | 11 |
| Estados del protocolo | 7 |

---

## 12. Limitaciones Actuales (Alcance MVP)

Por ser un MVP académico, el sistema tiene limitaciones intencionales:

- **Entorno 100% local**: no está desplegado en una red blockchain real (se usa Hardhat como simulador)
- **Autenticación simulada**: el login usa credenciales fijas de demostración, no verificación real de identidad
- **KYC cosmético**: la verificación de identidad es una simulación visual, sin integración con servicios reales
- **Sin pasarela de pago**: el USDC es falso (mock), generado por un faucet de prueba
- **Sin IPFS real**: las evidencias de los hitos usan URIs de ejemplo
- **Sin mercado secundario**: los tokens de proyecto no son transferibles

Estas limitaciones son naturales para un MVP y se resolverían en una versión productiva.

---

## 13. Aspectos Destacables del Desarrollo

### Lo que se logró hacer bien:

1. **Arquitectura modular**: cada proyecto tiene su propio contrato independiente, lo que evita que un fallo afecte a otros
2. **Máquina de estados estricta**: el contrato siempre sabe en qué estado está y qué operaciones permite, eliminando comportamientos impredecibles
3. **Votación ponderada**: a diferencia de "una persona un voto", aquí quien más arriesga más pesa en la decisión (modelo usado en DeFi real)
4. **Protección al inversor**: garantía del 5%, reembolsos proporcionales, snapshot anti-manipulación durante refunds
5. **Auditoría automática**: cada cambio de estado queda registrado en la base de datos sin intervención manual
6. **Tolerancia a fallos**: si la base de datos no está disponible, el sistema sigue funcionando con la blockchain
7. **Scripts de despliegue automatizados**: un solo comando levanta todo el entorno de desarrollo

---

## 14. Conclusiones

GreenFix demuestra que es viable construir una plataforma de financiamiento descentralizado utilizando tecnologías web modernas y blockchain. El MVP implementa exitosamente el ciclo completo del protocolo: desde la creación de un proyecto hasta la distribución de ganancias, pasando por votaciones descentralizadas y gestión de reembolsos.

El proyecto sienta las bases para una versión productiva que requeriría:

- Despliegue en una red blockchain real (ej. Polygon)
- Integración con USDC real y pasarelas de pago
- Sistema de autenticación con firma de wallet (estándar EIP-4361)
- Verificación de identidad (KYC/AML) con proveedores externos
- Almacenamiento descentralizado de evidencias (IPFS/Filecoin)
- Auditoría de seguridad profesional de los contratos inteligentes

---

*Documento generado como parte de la documentación del proyecto.*
*GreenFix — Plataforma de Micro-Crowdfunding Descentralizado — MVP Alpha*
