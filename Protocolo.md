**GreenFix Protocol — Arquitectura Final del MVP**

**1. Descripción General**

GreenFix es una plataforma descentralizada de microfinanciamiento basada en blockchain que permite a pequeños y medianos negocios obtener capital directamente de inversores mediante contratos inteligentes.

El sistema funciona como un modelo híbrido entre:

- Crowdfunding
- Lending DeFi
- Gobernanza descentralizada

La plataforma utiliza contratos inteligentes para:

- Bloquear fondos en escrow
- Liberar capital por hitos (milestones)
- Gestionar votaciones descentralizadas
- Distribuir reembolsos automáticamente
- Gestionar pagos de préstamos e intereses

El objetivo principal del MVP es validar la lógica financiera y operativa del protocolo.

**2. Modelo Financiero**

**2.1 Tokenización**

Cada proyecto crea su propio token ERC20.

Regla principal:

1 USDC invertido = 1 token del proyecto

Características del token:

- Representa participación proporcional del aporte
- Permite votar en las decisiones del proyecto
- Permite calcular reembolsos
- Permite calcular ganancias
- NO representa propiedad legal del negocio
- NO es transferible en el MVP

**2.2 Tipo de Financiamiento**

El protocolo utilizará un modelo de préstamo descentralizado.

El creador del proyecto:

- Solicita una cantidad específica de USDC
- Define el plazo del préstamo
- Define una tasa de interés fija
- Deposita una garantía inicial del 5%

Los inversores:

- Financian el proyecto
- Reciben tokens equivalentes a su inversión
- Obtienen retorno proporcional según el interés generado

**2.3 Interés**

El MVP utilizará:

- Interés simple
- Tasa fija por proyecto
- Sin interés compuesto

Ejemplo:

Préstamo: 1000 USDC

Interés: 6%

Total a devolver: 1060 USDC

**3. Arquitectura del Sistema**

**3.1 Arquitectura de Contratos**

El sistema utilizará una arquitectura modular.

**Contratos principales**

**GreenFixFactory.sol**

Responsabilidades:

- Crear proyectos
- Desplegar contratos de proyecto
- Registrar proyectos
- Mantener listado global de proyectos

**GreenFixProject.sol**

Cada proyecto tendrá su propio contrato independiente.

Responsabilidades:

- Custodia de fondos
- Gestión de milestones
- Gestión de votaciones
- Gestión de pagos
- Gestión de reembolsos
- Distribución de ganancias
- Estados del proyecto

**ProjectToken.sol**

Token ERC20 propio de cada proyecto.

Responsabilidades:

- Representar participación
- Permitir gobernanza
- Calcular retornos
- Calcular reembolsos

Características:

- No transferible
- Supply limitado al capital recaudado
- Se destruye al finalizar el proyecto

**4. Flujo General del Sistema**

**4.1 Flujo del Creador**

1. Crear proyecto
2. Definir:

- monto solicitado
- interés
- duración
- metadata

4. Depositar garantía del 5%
5. Esperar financiamiento
6. Solicitar liberación de milestones
7. Subir evidencias
8. Recibir fondos aprobados
9. Realizar pagos del préstamo
10. Finalizar proyecto

**4.2 Flujo del Inversor**

1. Explorar proyectos
2. Invertir USDC
3. Recibir tokens del proyecto
4. Participar en votaciones
5. Reclamar ganancias
6. Reclamar reembolsos si aplica

**5. Máquina de Estados del Protocolo**

El protocolo utilizará una máquina de estados estricta para garantizar comportamiento determinista y seguro.

Principio principal:

require(state == ProjectState.Active);

NO se utilizarán validaciones ambiguas como:

require(state != Cancelled);

Cada función debe ejecutarse únicamente en el estado exacto esperado.

**5.1 Enum de Estados**

enum ProjectState {

    Funding,

    Active,

    Voting,

    Refunding,

    Completed,

    Cancelled,

    Defaulted

}

**5.2 Estado Funding**

Estado inicial del proyecto.

**Funciones permitidas**

invest()

cancelFunding()

finalizeFunding()

**Funciones NO permitidas**

vote()

requestMilestoneRelease()

claimRefund()

makeRepayment()

**Transiciones**

**Funding completo**

Funding -> Active

**Expiración del tiempo de recaudación**

Funding -> Refunding

**Cancelación manual del creador**

Funding -> Cancelled

**5.3 Estado Active**

Proyecto funcionando normalmente.

Este estado cubre:

- ejecución operativa
- milestones
- repayments
- funcionamiento financiero

El protocolo NO utilizará un estado separado llamado Repayment.

Esto reduce complejidad y simplifica la lógica.

**Funciones permitidas**

requestMilestoneRelease()

makeRepayment()

**Restricciones**

- No puede existir votación activa
- El milestone actual no debe estar liberado
- El proyecto no debe estar en default

**Transiciones**

**Solicitud de milestone**

Active -> Voting

**Deuda pagada completamente**

Active -> Completed

**Incumplimiento de pago**

Active -> Defaulted

**5.4 Estado Voting**

Existe una votación activa.

**Funciones permitidas**

vote()

finalizeVoting()

**Funciones NO permitidas**

invest()

requestMilestoneRelease()

**Transiciones**

**Votación aprobada**

Voting -> Active

Además:

- Se liberan fondos del milestone
- Se marca milestone como liberado

**Primer rechazo**

Voting -> Active

Pero:

- El milestone se marca como retryUsed
- Puede intentarse nuevamente

**Segundo rechazo**

Voting -> Defaulted

**5.5 Estado Defaulted**

Proyecto incumplido.

**Funciones permitidas**

activateRefunds()

**Funciones NO permitidas**

makeRepayment()

requestMilestoneRelease()

vote()

**Transiciones**

Defaulted -> Refunding

**5.6 Estado Refunding**

Sistema de reembolso activo.

**Funciones permitidas**

claimRefund()

**Restricciones**

- Un solo claim por usuario
- No se permiten nuevas inversiones
- No se permiten milestones
- No se permiten repayments

**Transiciones**

Después del claim period:

Refunding -> Completed

**5.7 Estado Completed**

Estado terminal exitoso.

**Funciones permitidas**

claimRewards()

**Restricciones**

No se permiten más cambios operativos.

**5.8 Estado Cancelled**

Proyecto cancelado antes de activarse.

**Funciones permitidas**

claimRefund()

**5.9 Flujo Temporal Oficial**

**Flujo principal del proyecto**

Funding completo

↓

Funding -> Active

↓

Liberación de milestones

↓

Último milestone liberado

↓

Inicio automático de repayment

↓

Pagos parciales del creador

↓

Deuda = 0

↓

Completed

**5.10 Timers Globales**

El protocolo manejará tiempos explícitos.

uint256 fundingDeadline;

uint256 votingDuration;

uint256 repaymentInterval;

uint256 gracePeriod;

uint256 claimPeriod;

**Objetivos**

- Evitar ambigüedad temporal
- Permitir automatización
- Facilitar validaciones
- Garantizar determinismo

**5.11 Ejecución de Funciones Temporales**

Los contratos inteligentes no ejecutan acciones automáticamente.

Funciones como:

finalizeVoting()

serán ejecutadas manualmente.

Cualquier usuario podrá ejecutarlas siempre que:

require(block.timestamp > voteEnd);

Esto permite:

- descentralización
- automatización externa
- compatibilidad con bots o keepers

**5.12 Modifiers de Seguridad**

El protocolo utilizará modifiers estrictos.

Ejemplo:

modifier onlyState(ProjectState expected) {

    require(state == expected, "Invalid state");

    _;

}

Objetivos:

- formalizar reglas del protocolo
- evitar estados inválidos
- garantizar consistencia
- simplificar auditoría

**5.13 Basis Points para Intereses**

El protocolo NO utilizará decimales flotantes.

Se utilizarán basis points.

uint256 interestBps;

Ejemplos:

600 = 6%

1250 = 12.5%

Ventajas:

- precisión matemática
- compatibilidad Solidity
- menor riesgo de errores financieros

**5.14 Tokens y Trazabilidad**

Los tokens del proyecto NO serán transferibles.

Al finalizar el proyecto:

- los balances podrán mantenerse para trazabilidad
- el historial persistirá en blockchain
- la información histórica podrá almacenarse additionally en base de datos off-chain

El objetivo es:

- preservar auditoría histórica
- mantener inmutabilidad
- permitir análisis futuros

**6. Milestones**

El MVP utilizará milestones fijos.

Distribución:

[30%, 30%, 20%, 20%]

Cada milestone requiere:

- Evidencia subida a IPFS
- Apertura de votación
- Aprobación por mayoría

**6.1 Estructura del Milestone**

struct Milestone {

    uint8 percentage;

    uint256 amount;

    bool released;

    bool votingActive;

    uint256 voteStart;

    uint256 voteEnd;

    uint256 votesFor;

    uint256 votesAgainst;

    uint256 totalParticipation;

    string evidenceURI;

}

**7. Sistema de Votación**

**7.1 Modelo de Votación**

El peso del voto será proporcional a la cantidad de tokens.

1 token = 1 voto

**7.2 Snapshot**

Los balances se utilizarán directamente como peso de voto debido a que el token es no transferible.

Objetivo:

- Evitar manipulación de votos
- Congelar balances durante la votación

**7.3 Quórum**

Para validar una votación:

mínimo 40% de participación

**7.4 Aprobación**

El milestone se aprueba por:

Mayoría simple

Condición:

votos a favor > votos en contra

**7.5 Falta de Quórum**

**Primera vez**

- La votación se extiende 24 horas

**Segunda vez**

- El milestone se rechaza automáticamente
- El proyecto entra en revisión

**8. Sistema de Reembolso**

**8.1 Activación**

El sistema de refund se activa si:

- El proyecto entra en default
- El milestone es rechazado
- El creador desaparece
- El proyecto es cancelado
- El funding no alcanza el objetivo

**8.2 Cálculo del Reembolso**

Cada inversor recibe:

- Su porcentaje del capital restante
- Su porcentaje proporcional de la garantía del creador

Ejemplo:

Capital restante: 7000 USDC

Garantía: 500 USDC

Pool total: 7500 USDC

Inversor con 10%

→ recibe 750 USDC

**9. Sistema de Pagos**

**9.1 Modelo de Pago**

El creador devolverá:

- Capital
- Interés acordado

Mediante cuotas fijas.

**9.2 Tipos de Plazo**

**Corto plazo**

- Pagos semanales
- Duración reducida

**Mediano plazo**

- Pagos mensuales
- Mayor tiempo de devolución

**9.3 Incumplimiento**

Si el creador falla un pago:

1. Se abre votación de emergencia
2. Los inversores deciden:

- extender tiempo
- declarar default

Si se declara default:

- Se congela el proyecto
- Se activa refund
- Se distribuye garantía

**10. Seguridad del Sistema**

**Librerías y módulos utilizados**

**OpenZeppelin**

El protocolo utilizará:

Ownable

Pausable

ReentrancyGuard

SafeERC20

**Objetivos de Seguridad**

**ReentrancyGuard**

Evitar ataques de reentrancia.

**SafeERC20**

Transferencias seguras de USDC.

**Pausable**

Pausar el protocolo en emergencias.

**Ownable**

Administración de emergencia.

**11. Manejo de Fondos**

**Stablecoin**

El protocolo utilizará:

USDC

**Red Blockchain**

El MVP utilizará:

Polygon Amoy Testnet

Razones:

- Bajo costo de gas
- Compatibilidad EVM
- Buena experiencia de usuario
- Ideal para pruebas

**12. Gestión de Evidencias**

Las evidencias se almacenarán mediante:

IPFS

Blockchain solo almacenará:

string evidenceURI;

Ejemplos de evidencia:

- Facturas
- Fotografías
- PDFs
- Documentos
- Videos

**13. Sistema de Rewards y Distribución**

**13.1 Modelo de Distribución**

Las ganancias se distribuirán proporcionalmente según la cantidad de tokens del proyecto.

El protocolo utilizará un sistema de claim manual.

No existirán distribuciones automáticas.

Objetivos:

- reducir gas
- evitar loops costosos
- mejorar escalabilidad
- simplificar seguridad

**13.2 Variables de Rewards**

uint256 public totalRepaid;

mapping(address => uint256) public claimedRewards;

**13.3 Fórmula de Rewards**

La recompensa disponible se calculará mediante:

reward =

(userTokens / totalSupply)

*

totalRepaid

-

alreadyClaimed

**13.4 Prevención de Double Claim**

Cada usuario tendrá registro individual de rewards reclamadas.

Esto evita:

- múltiples reclamos
- inconsistencias contables
- explotación del sistema

**13.5 Burn de Tokens**

Los tokens serán destruidos al finalizar el ciclo financiero del usuario.

Flujo:

claimRewards()

↓

usuario recibe ganancias

↓

burn de tokens

El mismo mecanismo aplicará para refunds finales.

Objetivos:

- reducir storage activo
- cerrar contabilidad
- evitar holders fantasmas
- simplificar estado final

La trazabilidad histórica permanecerá disponible mediante:

- eventos blockchain
- logs on-chain
- base de datos off-chain
- analytics históricos

**14. Sistema de Repayments**

**14.1 Modelo de Cuotas**

El creador devolverá:

- capital
- intereses

mediante cuotas fijas.

**14.2 Estructura de Repayment**

struct Repayment {

    uint256 dueDate;

    uint256 amount;

    bool paid;

}

Repayment[] public repayments;

**14.3 Objetivos**

La estructura de repayments permitirá:

- detectar defaults
- verificar pagos
- gestionar historial
- automatizar lógica temporal
- simplificar auditoría

**14.4 Detección de Default**

Si una cuota excede:

dueDate + gracePeriod

cualquier inversor podrá ejecutar:

triggerDefaultVote()

**14.5 Votación de Emergencia**

Los inversores podrán decidir:

- extender plazo
- declarar default

Si se declara default:

Defaulted -> Refunding

**15. Sistema de Votación y Control**

**15.1 Prevención de Double Voting**

El protocolo utilizará:

mapping(uint256 => mapping(address => bool)) public hasVoted;

Objetivos:

- evitar votos duplicados
- garantizar integridad
- proteger gobernanza

**15.2 Milestone Activo**

El protocolo permitirá únicamente:

- un milestone activo
- una votación activa

uint256 public currentMilestone;

Los milestones deberán ejecutarse secuencialmente.

**15.3 Ejecución Manual de Finalizaciones**

Todas las transiciones temporales requerirán ejecución manual.

Ejemplos:

finalizeFunding()

finalizeVoting()

activateRefunds()

triggerDefaultVote()

Cualquier usuario podrá ejecutarlas si las condiciones son válidas.

Esto garantiza:

- descentralización
- comportamiento determinista
- compatibilidad con bots/keepers
- previsibilidad del protocolo

**16. Invariants del Protocolo**

El sistema deberá garantizar reglas que nunca pueden romperse.

**Invariants principales**

totalTokensMinted <= fundingGoal

releasedFunds <= totalRaised

totalRefunded <= refundPool

milestonePercentages == 100%

currentMilestone < totalMilestones

**Objetivos**

- facilitar testing
- facilitar auditorías
- simplificar debugging
- prevenir inconsistencias críticas

**17. Arquitectura de Datos y Metadata**

**On-Chain**

La blockchain almacenará únicamente:

- estados
- balances
- URIs
- montos
- hashes
- timestamps
- governance

Ejemplo:

string evidenceURI;

**Off-Chain**

El sistema externo almacenará:

- imágenes
- PDFs
- metadata pesada
- analytics
- historial indexado
- snapshots históricos

IPFS manejará el almacenamiento descentralizado de evidencias.

**18. Restricciones del Token ERC20**

El token del proyecto será completamente no transferible.

Solo se permitirá:

- mint
- burn

**Restricción principal**

require(

    from == address(0) || to == address(0),

    "Non-transferable"

);

**Objetivos**

- evitar especulación
- evitar compra de votos
- evitar trading secundario
- simplificar governance
- mantener modelo cerrado

**19. Fee de Plataforma**

La plataforma cobrará comisión únicamente sobre intereses generados.

Nunca sobre capital.

**Fórmula**

platformFee = interest × feeBps

**Ejemplo**

Interés generado = 60 USDC

Fee plataforma = 10%

Plataforma recibe = 6 USDC

Inversores reciben = 54 USDC

**Variable**

uint256 public platformFeeBps;

**20. Reglas del MVP**

**Tokens**

- No transferibles
- 1 token = 1 USDC
- Burn al finalizar proyecto

**Funding**

- Objetivo exacto
- Sin overfunding
- Si no se completa → refund total

**Inversión mínima**

10 USDC

**Garantía**

5% del monto solicitado

**Fee de plataforma**

La plataforma cobrará comisión únicamente sobre ganancias generadas.

No sobre capital invertido.

**21. Eventos Solidity**

**Eventos principales**

event ProjectCreated(uint256 indexed projectId, address indexed creator, uint256 fundingGoal);

event Invested(address indexed investor, uint256 amount, uint256 tokensMinted);

event MilestoneVotingStarted(uint256 milestoneId, uint256 startTime, uint256 endTime);

event Voted(address indexed investor, uint256 milestoneId, bool support, uint256 weight);

event MilestoneApproved(uint256 milestoneId);

event FundsReleased(uint256 milestoneId, uint256 amount);

event RefundActivated();

event RefundClaimed(address investor, uint256 amount);

event RepaymentMade(address creator, uint256 amount);

event ProjectCompleted();

**22. Edge Cases Definidos**

**Funding incompleto**

- Cancelación automática
- Refund total

**Creador desaparece**

- Freeze del proyecto
- Refund proporcional

**Whales**

El MVP aceptará whales.

Razones:

- Simplificación de gobernanza
- Consistencia con modelos DeFi reales
- Reducción de complejidad

**Sybil attacks**

No es prioridad crítica para el MVP debido a:

1 token = 1 voto

**23. Arquitectura Off-Chain**

**Backend (.NET)**

Responsabilidades:

- API REST
- Validaciones
- Gestión de usuarios
- Integración blockchain
- Notificaciones
- Monitoreo de eventos

**Frontend (React)**

Responsabilidades:

- Dashboard
- Visualización de proyectos
- Conexión wallet
- Gestión de inversiones
- Votaciones
- Reclamos

**Base de Datos**

Responsabilidades:

- Usuarios
- Historial
- Metadata
- Evidencias
- Analytics
- Logs

**24. Objetivo del MVP**

El MVP busca validar:

- La lógica financiera
- El modelo de gobernanza
- El flujo de escrow
- El sistema de milestones
- El sistema de reembolsos
- La interacción entre inversores y creadores

Antes de desarrollar una versión escalable y productiva.

**25. Limitaciones y Alcance del MVP**

El MVP tiene alcance académico y de validación conceptual.

No incluye:

- KYC
- AML
- regulación financiera completa
- sistema de oráculos
- liquidation engine
- DAO treasury governance
- mercado secundario
- upgradeability
- reputational scoring
- sistema legal automatizado

**Objetivo de las Limitaciones**

- reducir complejidad
- acelerar validación
- simplificar implementación
- enfocar recursos en lógica core

**26. Conclusión**

GreenFix propone una arquitectura híbrida entre crowdfunding y lending descentralizado utilizando contratos inteligentes en blockchain.

El protocolo prioriza:

- Transparencia
- Seguridad
- Automatización
- Protección del inversor
- Gobernanza descentralizada

El MVP se enfocará en validar la lógica central del sistema mediante una arquitectura modular segura y escalable sobre Polygon Amoy utilizando Solidity, React y .NET.