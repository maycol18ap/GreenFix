/**
 * Test autocontenido del fix de la "zona muerta" de inversión + votación.
 * Despliega contratos frescos en la red en proceso (no usa deployments.json
 * ni el nodo externo). Valida:
 *   - No se puede invertir < MIN_INVESTMENT cuando NO cierra la meta.
 *   - SÍ se puede invertir el remanente pequeño que cierra la meta exacta.
 *   - El funding finaliza y el flujo de votación libera el milestone.
 *
 * Uso: npx hardhat run scripts/test-deadzone.cjs
 */
const hre = require("hardhat");

const USDC = (n) => BigInt(Math.round(n * 1e6));
const fmt = (bn) => Number(bn) / 1e6;

async function main() {
  const { ethers } = hre;
  const [deployer, creator, investor] = await ethers.getSigners();

  // Despliegue fresco
  const MockUSDC = await ethers.getContractFactory("MockUSDC");
  const usdc = await MockUSDC.deploy();
  await usdc.waitForDeployment();
  const usdcAddr = await usdc.getAddress();

  const Factory = await ethers.getContractFactory("GreenFixFactory");
  const factory = await Factory.deploy(usdcAddr, 1000, 86400, 86400, 604800, deployer.address);
  await factory.waitForDeployment();

  console.log("\n🧪 TEST ZONA MUERTA + VOTACIÓN");

  const goal = USDC(3200);
  const guarantee = (goal * 5n) / 100n;
  await (await usdc.mint(creator.address, USDC(5000))).wait();
  await (await usdc.mint(investor.address, USDC(5000))).wait();

  // Crear proyecto (meta 3200)
  const rc = await (await factory.connect(creator).createProject(
    goal, 1000, 30, 7 * 24 * 3600, "ipfs://deadzone"
  )).wait();
  let projectAddress;
  for (const log of rc.logs) {
    try {
      const p = factory.interface.parseLog(log);
      if (p && p.name === "ProjectCreated") projectAddress = p.args[2];
    } catch {}
  }
  const project = await ethers.getContractAt("GreenFixProject", projectAddress);
  console.log("• Proyecto creado, meta:", fmt(goal), "USDC");

  // Garantía
  await (await usdc.connect(creator).approve(projectAddress, guarantee)).wait();
  await (await project.connect(creator).depositGuarantee()).wait();

  // Invertir 3198 → quedan 2 USDC (la zona muerta del bug)
  await (await usdc.connect(investor).approve(projectAddress, goal)).wait();
  await (await project.connect(investor).invest(USDC(3198))).wait();
  console.log("• Invertido 3198 | restante:", fmt(goal - await project.totalRaised()), "USDC");

  // Intentar invertir 1 USDC (NO cierra la meta) → debe revertir
  try {
    await project.connect(investor).invest(USDC(1));
    console.log("❌ FALLO: permitió 1 USDC que no cierra la meta");
    process.exitCode = 1;
    return;
  } catch {
    console.log("• ✅ Rechaza 1 USDC (no cierra meta y < mínimo) — correcto");
  }

  // Invertir los 2 USDC que cierran EXACTAMENTE la meta → antes revertía, ahora debe pasar
  await (await project.connect(investor).invest(USDC(2))).wait();
  console.log("• ✅ Aceptó los 2 USDC finales | totalRaised:", fmt(await project.totalRaised()), "USDC");

  // Finalizar funding (requiere meta exacta)
  await (await project.connect(creator).finalizeFunding()).wait();
  console.log("• ✅ Funding finalizado | estado:", Number(await project.state()), "(1 = Active)");

  // Votación: solicitar liberación, votar, finalizar
  await (await project.connect(creator).requestMilestoneRelease("ipfs://ev-1")).wait();
  await (await project.connect(investor).vote(0, true)).wait();
  const before = await usdc.balanceOf(creator.address);
  await (await project.connect(creator).finalizeVoting(0)).wait();
  const after = await usdc.balanceOf(creator.address);
  console.log("• ✅ Votación OK | milestone 0 liberó", fmt(after - before), "USDC al creador");

  console.log("\n🎉 ZONA MUERTA ELIMINADA — flujo de votación operativo\n");
}

main().catch((e) => {
  console.error("❌ Test falló:", e.shortMessage || e.message);
  process.exitCode = 1;
});
