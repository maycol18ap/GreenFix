# GreenFix — Frontend

Aplicación SPA en **React 19 + Vite** conectada a la blockchain mediante **ethers.js v6**. Es la interfaz principal de GreenFix.

## Stack

- **React 19** con Vite como bundler
- **Tailwind CSS v4** para estilos
- **ethers.js v6** para interacción con la blockchain
- **Framer Motion** para animaciones
- **Lucide React** para iconos

## Scripts

```bash
npm install     # instalar dependencias
npm run dev     # desarrollo en http://localhost:5173
npm run build   # build de producción en dist/
npm run preview # servir build localmente
npm run lint    # ESLint
```

## Estructura

```
src/
├── blockchain/          # Capa de conexión con blockchain
│   ├── web3Service.js   # Funciones on-chain (invest, vote, create, etc.)
│   ├── contractsConfig.js # Direcciones actualizadas por el deploy
│   └── abis/            # ABIs de los contratos
├── components/          # Componentes UI reutilizables
├── context/
│   └── AppContext.jsx   # Estado global (usuario, proyectos, wallet)
├── hooks/
│   ├── useProject.js    # Lógica de un proyecto individual
│   └── useFactory.js    # Interacción con GreenFixFactory
├── views/
│   ├── Home.jsx         # Landing page
│   ├── Dashboard.jsx    # Lista de proyectos
│   ├── ProjectDetail.jsx # Detalle: inversión, milestones, votación, pagos
│   └── CreateProject.jsx # Formulario de creación con KYC simulado
├── App.jsx
└── main.jsx
```

## Conexión con blockchain

El frontend se conecta directamente al nodo (Hardhat local o Polygon Amoy) mediante MetaMask. **No depende del backend** para las operaciones financieras.

Las operaciones on-chain incluyen: crear proyecto, invertir, votar, finalizar votación, solicitar liberación de hito, pagar cuotas, reclamar recompensas y reclamar reembolsos.

El backend se usa exclusivamente para: metadata de proyectos (nombre, descripción, imagen) y estadísticas/auditoría.
