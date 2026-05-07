# 🌱 GreenFix

Plataforma de Micro-Crowdfunding Descentralizado basada en Blockchain.

GreenFix busca permitir que pequeños negocios obtengan financiamiento mediante la tokenización de proyectos y el uso de Smart Contracts en blockchain.

---

# 📌 Tecnologías Utilizadas

## Frontend
- React.js
- Tailwind CSS
- Ethers.js

## Backend
- C# .NET 8
- ASP.NET Core Web API

## Blockchain
- Solidity
- Hardhat
- Ethereum / Polygon Testnet

## Base de Datos
- SQL Server

---

# 👥 Estructura del Proyecto

```bash
GreenFix/
│
├── frontend/     # Aplicación React
├── backend/      # API en C#
├── contracts/    # Smart Contracts Solidity
├── docs/         # Documentación del proyecto
└── README.md
```

---

# 🚀 Configuración Inicial

## 1. Configurar Git (SOLO UNA VEZ)

Antes de trabajar en el proyecto, configuren Git con su información:

```bash
git config --global user.name "Tu Nombre"
git config --global user.email "tu-correo@ejemplo.com"
```

---

# 📥 Clonar el Proyecto

```bash
git clone https://github.com/maycol18ap/GreenFix.git
cd GreenFix
```

Luego abrir la carpeta en VS Code.

---

# 🛠️ Instalación por Área

## 🎨 Frontend

Entrar a la carpeta frontend:

```bash
cd frontend
npm install
```

Para iniciar el proyecto:

```bash
npm run dev
```

---

## 🖥️ Backend

Entrar a backend:

```bash
cd backend
dotnet restore
```

Para ejecutar:

```bash
dotnet run
```

---

## 🔗 Smart Contracts

Entrar a contracts:

```bash
cd contracts
npm install
```

Compilar contratos:

```bash
npx hardhat compile
```

---

# 🧩 Extensiones Recomendadas VS Code

Instalar:

- C# Dev Kit
- ESLint
- Solidity (Nomic Foundation)
- Prettier
- GitLens (Opcional pero recomendado)

---

# 📋 Roles del Equipo

## 🧠 Líder / Blockchain
Responsable:
- Arquitectura
- Smart Contracts
- Integración blockchain

---

## 🎨 Frontend
Responsable:
- Diseño UI
- React
- Conexión Wallet

---

## 🖥️ Backend
Responsable:
- API REST
- Base de datos
- Lógica de servidor

---

## 🧪 QA / Testing
Responsable:
- Probar funcionalidades
- Detectar errores
- Verificar flujo del sistema

---

# ⚠️ Protocolo Diario (MUY IMPORTANTE)

## 🟢 Antes de empezar a trabajar

Siempre actualizar el proyecto:

```bash
git pull origin main
```

---

## 🔵 Después de terminar cambios

Guardar avances:

```bash
git add .
git commit -m "feat: descripción breve"
git push origin main
```

Ejemplos:
```bash
git commit -m "feat: crear login frontend"
git commit -m "fix: corregir endpoint proyectos"
```

---

# 🌿 Uso de Ramas (Recomendado)

NO trabajar directamente en `main` si el proyecto crece.

Ejemplo:

```bash
git checkout -b feature/frontend-home
```

Subir rama:

```bash
git push origin feature/frontend-home
```

---

# 📌 Reglas del Proyecto

## ✅ Hacer
- Código limpio
- Comentarios importantes
- Commits claros
- Avisar cambios importantes

## ❌ Evitar
- Borrar código ajeno
- Cambiar archivos sin avisar
- Subir código roto
- Hacer push sin antes usar `git pull`

---

# 🎯 Objetivo del MVP

El MVP debe permitir:

- Crear proyectos
- Visualizar proyectos
- Invertir usando testnet
- Votar milestones
- Liberar o rechazar fondos

---

# 🚧 Funciones NO prioritarias

Estas NO son prioridad del MVP:

- Marketplace de tokens
- Trading entre usuarios
- Sistema financiero completo
- App móvil
- IA avanzada

---

# 🔐 Flujo General del Sistema

1. El creador publica un proyecto
2. Usuarios invierten mediante wallet
3. Fondos quedan bloqueados
4. El creador sube avances
5. Inversores votan
6. Se liberan o rechazan fondos

---

# 🧠 Filosofía del Proyecto

GreenFix NO busca reemplazar bancos completamente.

Busca:
- Democratizar inversión
- Facilitar acceso a financiamiento
- Utilizar blockchain para transparencia
- Proteger al inversor mediante smart contracts

---

# 📚 Recursos Recomendados

## React
https://react.dev/

## .NET
https://learn.microsoft.com/en-us/dotnet/

## Solidity
https://soliditylang.org/

## Hardhat
https://hardhat.org/

## Ethers.js
https://docs.ethers.org/

---

# 🚀 Estado Actual

🟡 En desarrollo (MVP / Alpha)

---

# 📌 Notas Finales

- Mantener comunicación constante
- Si algo falla, avisar
- Priorizar funcionalidad antes que diseño
- Mantener el MVP simple
