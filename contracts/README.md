# GreenFix — Smart Contracts

Contratos inteligentes en **Solidity 0.8.28** desplegados con **Hardhat 3**. Son el núcleo financiero de GreenFix.

## Stack

- **Solidity 0.8.28**
- **Hardhat 3 Beta** (compilación, testing, despliegue)
- **OpenZeppelin 5.2** (ReentrancyGuard, Pausable, SafeERC20, Ownable)
- **ethers.js v6** (interacción en scripts y tests)

## Scripts

```bash
npm install
npm run node           # nodo local en http://127.0.0.1:8545
npm run compile        # compilar contratos
npm run deploy:local   # desplegar + faucet + actualizar frontend config
npm run test           # tests (Foundry + Hardhat)
```

## Contratos

| Contrato | Archivo | Rol |
|----------|---------|-----|
| **GreenFixFactory** | `contracts/core/GreenFixFactory.sol` | Fábrica global: crea y registra proyectos |
| **GreenFixProject** | `contracts/core/GreenFixProject.sol` | Núcleo: escrow, milestones, votación, pagos, reembolsos |
| **ProjectToken** | `contracts/core/ProjectToken.sol` | ERC20 no transferible (1 token = 1 USDC invertido) |

### Arquitectura

```
GreenFixFactory (una sola, global)
    │
    ├── new GreenFixProject(...) ← cada proyecto es una instancia independiente
    │       │
    │       └── new ProjectToken(...) ← token propio de cada proyecto
    │
    └── Registro global: projects[projectId] → {dirección, creador, meta, ...}
```

Cada proyecto tiene su propia dirección, su propio estado y su propio token. Si un proyecto falla, los demás no se ven afectados.

## Tests

```bash
npx hardhat test
```

| Categoría | Tests | Qué valida |
|-----------|-------|------------|
| Funding | 7 | Crear proyecto, garantía, invertir, cancelar, finalizar |
| Milestones | 9 | Liberación, votar, finalizar, doble rechazo → default |
| Refunds | 6 | Activar, calcular montos, reclamar, anti-doble claim |
| Repayments | 5 | Pagar cuotas, completar, reclamar rewards, declarar default |

**Total: 27 tests.**

### Smoke test (flujo completo E2E)

```bash
npx hardhat run scripts/smoke.cjs --network localhost
# → 🎉 FLUJO COMPLETO OK
```

Ejecuta: crear proyecto → garantía → invertir → milestone → vota → libera → repaga → completa → reclama.

## Seguridad

- `ReentrancyGuard` — previene ataques de reentrancia
- `SafeERC20` — transferencias seguras de USDC
- `Pausable` — pausa de emergencia
- `onlyState(ProjectState)` — máquina de estados estricta
- Basis Points (BPS) para intereses — sin floats
- Snapshot de supply al activar reembolsos — anti-manipulación
