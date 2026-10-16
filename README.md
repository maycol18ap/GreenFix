# GreenFix

**Micro-crowdfunding descentralizado para pequeños negocios.**

Conecta emprendedores que necesitan capital con inversores que buscan rendimiento, todo gobernado por contratos inteligentes — sin bancos, sin intermediarios, sin opacidad.

> **Stack:** Solidity · React 19 · .NET 10 · SQL Server · IPFS · Polygon Amoy

---

## El problema

Los pequeños negocios son el motor de cualquier economía, pero enfrentan una barrera brutal para crecer:

- **Crédito inaccesible:** requiere historial crediticio, garantías excesivas y meses de papeleo
- **Tasas abusivas:** cuando logran acceder, los intereses los ahogan
- **Falta de transparencia:** no saben qué pasó con su dinero ni cuándo lo van a recuperar

Del otro lado, las personas comunes quieren invertir pero solo tienen acceso a instrumentos tradicionales de bajo rendimiento. No pueden financiar un proyecto local que les importa.

## La solución

GreenFix es un **protocolo de préstamos descentralizados** donde:

1. Un emprendedor publica un proyecto, define cuánto necesita, y deposita una **garantía del 5%**
2. Los inversores financian el proyecto con USDC y reciben tokens de participación
3. Los fondos se liberan por **hitos (milestones)** que los inversores aprueban por votación
4. El emprendedor devuelve capital + interés en **cuotas fijas**
5. Si algo sale mal, los inversores reclaman su capital de forma proporcional

Todo on-chain, todo transparente, todo automático.

## Por qué blockchain

| Sin blockchain | Con blockchain (GreenFix) |
|----------------|---------------------------|
| Promesas y confianza | Contratos que ejecutan reglas |
| Intermediarios que cobran comisiones | Fee del 10% solo sobre ganancias |
| Procesos manuales y opacos | Cada acción es un evento verificable |
| Depender de una plataforma central | Cualquiera puede auditar el protocolo |

## Cómo funciona

### Flujo del creador

```
Crea proyecto → Deposita garantía (5%) → Recibe inversiones
→ Solicita liberación de hito con evidencia → Inversores votan
→ Recibe fondos del hito → Paga cuotas → Proyecto completado
```

### Flujo del inversor

```
Explora proyectos → Invierte USDC (mín. 10) → Recibe tokens
→ Vota en hitos (1 token = 1 voto) → Reclama ganancias al finalizar
```

### Máquina de estados

```
Funding ──→ Active ──→ Voting ──→ Active (siguiente hito)
   │          │          │
   │          │          └──→ Defaulted ──→ Refunding
   │          └──→ Completed (deuda saldada)
   └──→ Cancelled
```

7 estados estrictos. Cada función del contrato exige el estado exacto esperado. Nada de ambigüedades.

## Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                     USUARIO + MetaMask                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
   ┌─────────────┐        ┌──────────────┐
   │  FRONTEND   │        │   BACKEND    │
   │  React 19   │◄──────►│   .NET 10    │
   │  ethers.js  │  HTTP  │   EF Core 8  │
   └──────┬──────┘        └──────┬───────┘
          │                      │
          ▼                      ▼
   ┌─────────────┐        ┌──────────────┐
   │ BLOCKCHAIN  │        │  SQL SERVER  │
   │  Polygon /  │        │  Metadata +  │
   │  Hardhat    │        │  Auditoría   │
   └─────────────┘        └──────────────┘
```

**Principio clave:** la blockchain es la **fuente de verdad** financiera. El backend guarda metadata y estadísticas. Si el backend está apagado, el frontend sigue funcionando.

## Smart Contracts

| Contrato | Rol |
|----------|-----|
| `GreenFixFactory` | Fábrica global: crea y registra proyectos |
| `GreenFixProject` | Núcleo: escrow, milestones, votación, pagos, reembolsos |
| `ProjectToken` | ERC20 no transferible (1 token = 1 USDC invertido) |

Cada proyecto es una **instancia independiente** con su propio contrato y token. La Factory es el punto de entrada.

### Seguridad

- **OpenZeppelin 5.2** — `ReentrancyGuard`, `Pausable`, `SafeERC20`
- **Máquina de estados estricta** — `onlyState(ProjectState expected)` en cada función
- **Basis Points (BPS)** — sin floats: `600 = 6%`, `1250 = 12.5%`
- **Snapshot anti-manipulación** en reembolsos (congela balances al activar refund)
- **Prevención de double-vote** y **double-claim** con mappings de rastreo

## Reglas financieras

| Parámetro | Valor |
|-----------|-------|
| Tokenización | 1 USDC invertido = 1 token (no transferible, se quema al finalizar) |
| Garantía del creador | 5% del monto solicitado — va al pool de reembolso si el proyecto falla |
| Interés | Simple, tasa fija: 6% (≤1K), 8% (≤2.5K), 10% (>2.5K) |
| Inversión mínima | 10 USDC |
| Overfunding | No permitido — meta exacta |
| Milestones | 4 hitos: 30% + 30% + 20% + 20% |
| Quórum | 51% de participación mínima |
| Aprobación | Mayoría simple |
| Rechazo de hito | 1º reintento libre, 2º → Default |
| Fee de plataforma | 10% sobre intereses generados (nunca sobre capital) |

## Quick Start

> **Requisitos:** Node.js 18+, .NET SDK 10, MetaMask. SQL Server es opcional.

```bash
# 1. Nodo blockchain (Terminal 1 — dejar siempre abierto)
cd contracts && npm install && npm run node

# 2. Desplegar contratos + faucet + ABIs (Terminal 2)
cd contracts && npm run deploy:local

# 3. Backend (Terminal 3, opcional)
cd backend && dotnet run

# 4. Frontend (Terminal 4)
cd frontend && npm install && npm run dev
```

Abrir `http://localhost:5173` en el navegador.

### Verificar que todo funciona

```bash
cd contracts
npx hardhat run scripts/smoke.cjs --network localhost
# → 🎉 FLUJO COMPLETO OK
```

> **Guía detallada de ejecución local:** [`RUN-LOCAL.md`](RUN-LOCAL.md)

## Estructura del repositorio

```
GreenFix/
├── contracts/              # Smart Contracts (Solidity + Hardhat 3)
│   ├── contracts/          #   Factory, Project, Token
│   ├── scripts/            #   deploy.cjs, smoke.cjs
│   └── test/               #   27 tests (Foundry + Hardhat)
├── frontend/               # SPA React 19 + Vite + ethers.js
│   └── src/
│       ├── blockchain/     #   web3Service, ABIs, config
│       ├── components/     #   UI components
│       ├── context/        #   estado global (AppContext)
│       ├── hooks/          #   useProject, useFactory
│       └── views/          #   Home, Dashboard, ProjectDetail, CreateProject
├── backend/                # API REST (.NET 10 + EF Core)
│   ├── Controllers/        #   10 controladores
│   ├── Models/             #   9 modelos
│   └── Data/               #   DbContext + migraciones
├── database/               # Scripts SQL Server (idempotentes)
├── docs/                   # Documentación
├── Protocolo.md            # Especificación completa del protocolo
└── RUN-LOCAL.md            # Guía de ejecución local
```

## Estado actual

| Área | Progreso | Detalle |
|------|----------|---------|
| Smart Contracts | 🟡 ~65% | Arquitectura sólida; bug en `finalizeVoting`; 4 transiciones pendientes |
| Frontend | 🟡 ~25% | UI completa; 3 de 15 funciones on-chain implementadas |
| Backend | 🔴 ~30% | 3 de 9 controladores implementados |
| Tests | 🟢 ~70% | 27 unitarios; faltan E2E y edge cases |
| Documentación | 🟢 ~85% | Protocolo, guía local, notas de arquitectura |

**El MVP valida el flujo completo en local:** crear → invertir → votar → liberar → pagar → reclamar. La integración on-chain/off-chain es el siguiente crítico a cerrar.

## Tests

```bash
cd contracts
npx hardhat test                                    # 27 tests unitarios
npx hardhat run scripts/smoke.cjs --network localhost  # E2E: flujo completo
```

## Roadmap

### Fase 1 — MVP (actual)
- [x] Arquitectura de contratos modular
- [x] Flujo completo on-chain validado en local
- [x] UI funcional con conexión a wallet
- [ ] Corregir bug `finalizeVoting` (doble emisión de evento)
- [ ] Implementar 12 funciones blockchain faltantes en frontend
- [ ] Implementar 6 controladores restantes en backend
- [ ] Cerrar gap de integración on-chain/off-chain
- [ ] Tests E2E con ethers.js

### Fase 2 — Testnet
- [ ] Despliegue en Polygon Amoy
- [ ] USDC real + faucet de MATIC
- [ ] IPFS real para evidencias
- [ ] Autenticación por firma de wallet (EIP-4361)

### Fase 3 — Producto
- [ ] Worker Service como oráculo (finalización automática de votaciones)
- [ ] KYC on-chain (mapping `kycVerified` por proyecto)
- [ ] Panel de administración
- [ ] Sistema de reputación

### Fuera de alcance
Marketplace secundario · Trading entre usuarios · App móvil · IA · Upgradeability · DAO treasury

## Documentación

| Recurso | Descripción |
|---------|-------------|
| [`Protocolo.md`](Protocolo.md) | Especificación completa del protocolo (máquina de estados, edge cases, invariants) |
| [`RUN-LOCAL.md`](RUN-LOCAL.md) | Guía de ejecución local paso a paso |
| [`docs/INFORME_PROYECTO.md`](docs/INFORME_PROYECTO.md) | Informe académico |
| `contracts/README.md` | Detalles de los contratos y tests |
| `frontend/README.md` | Detalles del frontend |
| `database/README.md` | Scripts de base de datos |

---

**GreenFix** — Transparencia, seguridad y gobernanza descentralizada para el financiamiento de pequeños negocios.
