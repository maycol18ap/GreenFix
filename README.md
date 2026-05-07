🚀 Guía de Inicio: Proyecto GreenFix
¡Hola equipo! Ya tenemos la estructura base del proyecto en GitHub. Por favor, sigan estos pasos en orden para configurar su entorno de trabajo en VS Code.

1. Configuración Inicial (Solo la primera vez)
Antes de descargar el código, asegúrense de que Git sepa quiénes son para que no les dé errores al subir cambios:

Abran una terminal en VS Code y escriban:

Bash
git config --global user.name "Tu Nombre Real"
git config --global user.email "tu-correo-de-github@ejemplo.com"
2. Descargar el Proyecto
Busquen una carpeta donde guarden sus proyectos de la U y ejecuten:

Bash
git clone https://github.com/maycol18ap/GreenFix.git
cd GreenFix
Luego, abran esa carpeta GreenFix con VS Code.

3. Instalación de Herramientas
Cada uno debe entrar a su "zona" de trabajo para instalar lo necesario. Abran la terminal de VS Code y corran el comando que les corresponda:

Si vas a trabajar en Frontend (React):

Bash
cd frontend
npm install
Si vas a trabajar en Backend (C#):

Bash
cd backend
dotnet restore
Si vas a trabajar en Smart Contracts (Solidity):

Bash
cd contracts
npm install
4. Extensiones Recomendadas en VS Code
Para que el código no se vea todo blanco y negro, instalen estas extensiones:

C# Dev Kit (Para el Backend).

ESLint (Para el Frontend).

Solidity (Nomic Foundation) (Para los Smart Contracts).

Prettier (Para que el código se vea ordenado).

5. El "Protocolo Diario" (Para no romper nada)
Para evitar conflictos y errores de "código perdido", sigan siempre este flujo:

🟢 Al empezar a trabajar:
Bash
git pull origin main
(Esto descarga los últimos cambios que tus compañeros hayan subido).

🔵 Al terminar tu avance:
Guarda todo en VS Code.

En la terminal escribe:

Bash
git add .
git commit -m "Explicación breve de lo que hiciste (ej: feat: crear login)"
git push origin main
